%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the Log Determinant used in mHMC
%   It is dependent 
%   - inverse of the NEgative Hessian
%   - Derivative of the negative Hessian
%   - Possibly other parameters if a transformation has been applied to the
%   Negative Hessian
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DerivativeInvNegHessian=ComputationDerivativeInverseNegHessian(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,BlockSize,TempAux,AlphaPosDefMatrix,ModelParam)


DerivativeInvNegHessian=zeros(BlockSize,1);


if isempty(Veig)==1 % 
    for k=1:BlockSize
        switch ModelParam.setup.example_name
            case 'Septier16' % Indepdendent Observations
                DerivativeInvNegHessian(k,1)=TempAux'*InvNegHessian(:,k)*DerivativeNegHessian(k,1)*InvNegHessian(k,:)*TempAux;
            otherwise
                DerivativeInvNegHessian(k,1)=TempAux'*InvNegHessian*DerivativeNegHessian(:,:,k)*InvNegHessian*TempAux;
        end
    end
else % Derivative by following SoftABS Method [Betancourt 2014]
    
% Compute the derivative by taking into
    % account the modified NegHessian

    EigenValueVector=diag(Deig);
    MatrixJ=zeros(BlockSize,BlockSize);
    for k=1:BlockSize
        for kk=1:BlockSize
            if k==kk || EigenValueVector(k)==EigenValueVector(kk)
                MatrixJ(k,kk)=coth(AlphaPosDefMatrix*EigenValueVector(k))-AlphaPosDefMatrix*EigenValueVector(k)*csch(AlphaPosDefMatrix*EigenValueVector(k))^2;
            else %Derivative

                MatrixJ(k,kk)=(EigenValueVector(k)*coth(AlphaPosDefMatrix*EigenValueVector(k))-EigenValueVector(kk)*coth(AlphaPosDefMatrix*EigenValueVector(kk)))...
                    /(EigenValueVector(k)-EigenValueVector(kk));
            end
        end
    end 
    MatrixM=inv(DeigTrans)*Veig';  
    %MatrixR=diag(1./(EigenValueVector.*coth(AlphaPosDefMatrix*EigenValueVector)));    
    
    for num=1:BlockSize
        DerivativeInvNegHessian(num,1)=TempAux'*MatrixM'*((MatrixJ.*Veig')*(DerivativeNegHessian(:,:,num))*Veig)*MatrixM*TempAux;
    end
end

DerivativeInvNegHessian=real(DerivativeInvNegHessian);