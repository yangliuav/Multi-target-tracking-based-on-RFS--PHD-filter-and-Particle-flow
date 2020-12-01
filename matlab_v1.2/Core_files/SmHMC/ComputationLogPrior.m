function [LogPrior]=ComputationLogPrior(State,CurrentMean,ModelParam)

% 
% if strcmp(ModelParam.ModelState,'Normal')
%     
%     % Poisson Observation Model
% 
% %     IntensityPoisson=ModelParam.MappingIntensityFunction(Mean,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale);
% % 
% %     LogLikelihood=sum(Obs.*log(IntensityPoisson)-IntensityPoisson);
% 
%     LogPrior=ComputationLogNormal(State,CurrentMean,ModelParam.StateCovarianceInv,ModelParam.StateCovariance);
%     
% elseif strcmp(ModelParam.ModelState,'SkewedT')
    
    
    %[LogPrior]=ComputationLogPriorSkewedTv1(State,PreviousState,ModelParam);
    LogPrior=ComputationLogPriorSkewedTv1(State,CurrentMean,ModelParam);

% end

