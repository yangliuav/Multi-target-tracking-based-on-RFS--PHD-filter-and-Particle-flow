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
function DerivativeLogDeterminant=ComputationDerivativeLogDeterminant(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,BlockSize,AlphaPosDefMatrix,ModelParam)

DerivativeLogDeterminant=zeros(BlockSize,1);

if isempty(Veig)==1 % 
    switch ModelParam.setup.example_name
        case 'Septier16' % Independent Observaitons
            DerivativeLogDeterminant=diag(InvNegHessian).*DerivativeNegHessian;
        otherwise
            for k=1:BlockSize
                DerivativeLogDeterminant(k,1)=trace(InvNegHessian*DerivativeNegHessian(:,:,k));        
            end
    end
else
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
   
    MatrixR=diag(1./(EigenValueVector.*coth(AlphaPosDefMatrix*EigenValueVector)));
    
    for k=1:BlockSize
        DerivativeLogDeterminant(k,1)=trace(Veig*(MatrixR.*MatrixJ)*Veig'*(DerivativeNegHessian(:,:,k)));%*(DerivativeNegHessianPrior(:,:,kk)+DerivativeNegHessianLikelihood(:,:,kk)));
    end    
end

DerivativeLogDeterminant=real(DerivativeLogDeterminant);