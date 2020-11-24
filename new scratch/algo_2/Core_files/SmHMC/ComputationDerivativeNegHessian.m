%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   COmpute Derivative NEg Hessian Complete Likelihood Current Time
%       p(x_{t,k},y_t|x_{t,\k},x_{1:t-1},y_{1:t-1}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [DerivativeNegHessian]=ComputationDerivativeNegHessian(Obs,MatrixTransformation,BlockSize,CondMean,InvCondCov,RearrangedCurrentState,ModelParam)

%%%%%%%%%
% Note to accelerate code owing to the specific properties of the
% independence of the observation (i.e. diagonal matrix)
% Otherwise DerivativeNegHessian of size (BlockSize,BlockSize,BlockSize)



CurrentState=RearrangedCurrentState(1:BlockSize,1);
RearrangedObs=MatrixTransformation*Obs;
RearrangedObs=RearrangedObs(1:BlockSize,1);

switch ModelParam.setup.example_name
    case 'Septier16'
        DerivativeNegHessianLikelihood=zeros(BlockSize,1);
        DerivativeNegHessianLikelihood=ModelParam.MappingIntensityFunctionThirdDeriv(CurrentState(:),ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale);
        DerivativeNegHessianPrior=zeros(BlockSize,1);
    otherwise
        error('undefined negative hessian')
        DerivativeNegHessianLikelihood=zeros(BlockSize,1);%zeros(BlockSize,BlockSize,BlockSize);
end

DerivativeNegHessian=real(DerivativeNegHessianLikelihood+DerivativeNegHessianPrior);