%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   COmpute Gradient Complete Likelihood Current Time
%       p(x_{t,k},y_t|x_{t,\k},x_{1:t-1},y_{1:t-1}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [Gradient]=ComputationGradient(Obs,MatrixTransformation,BlockSize,CondMean,InvCondCov,RearrangedCurrentState,ModelParam)


CurrentState=RearrangedCurrentState(1:BlockSize,1);
RearrangedObs=Obs;
% RearrangedObs=RearrangedObs(1:BlockSize,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation Gradient Likelihood

switch ModelParam.setup.example_name
    case 'Septier16'
        GradientLikelihood=(RearrangedObs.*ModelParam.MappingIntensityFunctionFirstDerivLog(CurrentState,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale)...
            -ModelParam.MappingIntensityFunctionFirstDeriv(CurrentState,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale));
            
        %disp('passe')
        %InvCondCov=inv(CondCov);
        CondSkewness=MatrixTransformation*ModelParam.StateSkewness;%(1)*ones(size(CondMean));
        Lambda=-0.5*ModelParam.StateDegreeFreedom;
        Chi=ModelParam.StateDegreeFreedom;
        Psi=0;
        TermQ=(CurrentState-CondMean)'*(InvCondCov)*(CurrentState-CondMean);

        Alpha=Psi+CondSkewness'*InvCondCov*CondSkewness;
        TermSR=sqrt(Alpha*Chi+Alpha*TermQ);

        % Asymptotic Approx of Bessel when order is large
        ApproxRatioBess=@(v,z) exp(0.5*log(v./(v-1))-(1-v).*log((exp(1)*z)./(2*(1-v)))-v.*log((exp(1)*z)./(2*(-v))));

        RatioBessel=(besselk(Lambda-(BlockSize)/2-1,TermSR,1)/besselk(Lambda-(BlockSize)/2,TermSR,1));
        if isnan(RatioBessel)
            RatioBessel=ApproxRatioBess(Lambda-(BlockSize)/2,TermSR);
        end
        GradientPrior=InvCondCov*CondSkewness...
            -RatioBessel*((Alpha*Chi+Alpha*TermQ)^(-1/2))*(Alpha*InvCondCov*(CurrentState-CondMean));    

        GradientPrior=real(GradientPrior);
        
    case 'Acoustic'
        GradientLikelihood=ModelParam.likeparams.dh_dx_func(CurrentState,ModelParam.likeparams)'*ModelParam.likeparams.R_inv*(RearrangedObs-ModelParam.likeparams.h_func(CurrentState,ModelParam.likeparams));
        GradientPrior=-InvCondCov*(CurrentState-CondMean);
end

Gradient=real(GradientPrior+GradientLikelihood);