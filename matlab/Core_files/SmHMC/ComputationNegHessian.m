%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   COmpute Neg Hessian Complete Likelihood Current Time
%       p(x_{t,k},y_t|x_{t,\k},x_{1:t-1},y_{1:t-1}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [NegHessian,Veig,Deig,DeigTrans]=ComputationNegHessian(Obs,MatrixTransformation,BlockSize,CondMean,InvCondCov,RearrangedCurrentState,ModelParam)

CurrentState=RearrangedCurrentState(1:BlockSize,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation Gradient Likelihood

switch ModelParam.setup.example_name
    case 'Septier16'
        % If Exponential is used as link function in the Poisson
        DiagonalTerm=-ModelParam.MappingIntensityFunctionSecDeriv(CurrentState,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale);
        DiagonalTerm(isnan(DiagonalTerm))=-1;
        HessianLikelihood=diag(DiagonalTerm);
        HessianPrior=-ModelParam.InvStateCovSkewedT;
    case 'Acoustic'
%         ModelParam.VarNoise = ModelParam.propparams.Q(1);
%         HessianLikelihood=-(1/ModelParam.VarNoise)*eye(size(CurrentState,1));
        dh_dx = (ModelParam.likeparams.dh_dx_func(CurrentState,ModelParam.likeparams))';
        dHdx = ModelParam.likeparams.dH_dx_func(CurrentState,ModelParam.likeparams);
        diff = (Obs-ModelParam.likeparams.h_func(CurrentState,ModelParam.likeparams));
        HessianLikelihood=zeros(size(InvCondCov));
        for i = 1:size(HessianLikelihood,1)
            HessianLikelihood(:,i) = -dh_dx*ModelParam.likeparams.R_inv*dh_dx(i,:)'...
                +dHdx(:,:,i)*ModelParam.likeparams.R_inv*diff;
        end
        HessianPrior=-InvCondCov;
end

NegHessian=real(-HessianPrior-HessianLikelihood);

% % if not positive definite, use SoftAbs
% [R,p] = chol(NegHessian);
% if p > 0
%     [V,D]=eig(NegHessian);
%     alpha = 0.01;
%     exp_plus = exp(alpha*NegHessian);
%     exp_minus = exp(-alpha*NegHessian);
%     softAbs_map = (exp_plus+exp_minus)*NegHessian*inv(exp_plus-exp_minus);
% end


Veig=[]; % Eigenvectors
Deig=[]; % Matrix with eigenvalues on diagonal
DeigTrans=[]; % Matrix with eigenvalues on diagonal