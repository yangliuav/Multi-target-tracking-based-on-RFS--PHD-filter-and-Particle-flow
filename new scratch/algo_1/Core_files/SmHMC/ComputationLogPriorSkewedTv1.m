function [LogPrior]=ComputationLogPriorSkewedTv1(State,CurrentMean,ModelParam)

% Computation of the full prior which is Multivariate GH Skewed t-distribution
% ModelParam.StateDegreeFreedom
% ModelParam.StateCovariance
% ModelParam.StateCovarianceInv
% Skewness=ModelParam.StateSkewness;

%CurrentMean=ModelParam.TransitionMatrix*PreviousState;
TermQ=(State-CurrentMean)'*ModelParam.StateCovarianceInv*(State-CurrentMean);
TermSR=sqrt((ModelParam.StateDegreeFreedom+TermQ)*ModelParam.StateSkewness'*ModelParam.StateCovarianceInv*ModelParam.StateSkewness);


ApproxLogBesselFactor=@(v,z) 0.5*log(pi/(2*abs(v)))-abs(v)*log((exp(1)*z)/(2*abs(v)));

LogBesselkFactor=log(besselk((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2,TermSR,1))-TermSR; % Use of besselk(nu,Z,1) which computes besselk(nu,Z).*exp(Z).
%[log(besselk((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2,TermSR)) LogBesselkFactor ApproxLogBesselFactor((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2,TermSR)]
%LogBesselkFactor
if isinf(LogBesselkFactor)==1
    LogBesselkFactor=ApproxLogBesselFactor((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2,TermSR);
end

%LogBesselkFactor
%pause

LogPrior=LogBesselkFactor...
    +(State-CurrentMean)'*ModelParam.StateCovarianceInv*ModelParam.StateSkewness...
    +((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2)*log(TermSR)...
    -((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2)*log(1+TermQ/ModelParam.StateDegreeFreedom);


%pause
% % Second Expression Which should be equivalent
% LogPrior2=log(besselk(-(ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2,TermSR))...
%     +(State-CurrentMean)'*ModelParam.StateCovarianceInv*ModelParam.StateSkewness...
%     -((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2)*log(TermSR);
% LogPrior-LogPrior2 
% pause

% Do not need to compute this term !!
LogNormConstant=(1-((ModelParam.StateDegreeFreedom+ModelParam.Dimension)/2))*log(2)...
    -log(gamma(ModelParam.StateDegreeFreedom/2))...
    -(ModelParam.Dimension/2)*log(pi*ModelParam.StateDegreeFreedom)...
    -0.5*log(ModelParam.StateCovarianceDet);

LogPrior=LogPrior;%+LogNormConstant;

%exp(LogNormConstant)

% 
% 
% 
% IntensityPoisson=ModelParam.MappingIntensityFunction(Mean,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale);
% 
% LogLikelihood=sum(Obs.*log(IntensityPoisson)-IntensityPoisson);
% 
% 
% 
% 
% 
% 
% 
%         Argument=([Xsensors(n,nn);YSensors(n,nn)]-MeanFunction([Xsensors(n,nn);YSensors(n,nn)]))'...
%             *inv(Covariance)*([Xsensors(n,nn);YSensors(n,nn)]-MeanFunction([Xsensors(n,nn);YSensors(n,nn)]));
%         
%         SecondArg=sqrt((DegreeFreedom+Argument)*Skewness'*inv(Covariance)*Skewness);
%         
%         FirstTerm=besselk((DegreeFreedom+Dim)/2,SecondArg);
%         ExpoTerm=exp(([Xsensors(n,nn);YSensors(n,nn)]-MeanFunction([Xsensors(n,nn);YSensors(n,nn)]))' *inv(Covariance)*Skewness);
%         Denomintator=(SecondArg^(-(DegreeFreedom+Dim)/2))*(1+Argument/DegreeFreedom)^((DegreeFreedom+Dim)/2);
%         
%         
%         Distribution(n,nn)=FirstTerm*ExpoTerm/Denomintator;
%         
%         NormalizingConstant=(2^(1-(DegreeFreedom+Dim)/2))/((det(Covariance)^(1/2))*gamma(DegreeFreedom/2)*(pi*DegreeFreedom)^(Dim/2));
% % Normal Observation
%LogLikelihood=sum(-(1/(2*ModelParam.VarNoise))*(Obs-Mean).^2);