function [LogLikelihood]=ComputationLogLikelihoodv1(Obs,Mean,ModelParam)


% if strcmp(ModelParam.ModelObservation,'Poisson')
    
    % Poisson Observation Model

    IntensityPoisson=ModelParam.MappingIntensityFunction(Mean,ModelParam.MappingIntensityCoeff,ModelParam.MappingIntensityScale);

    LogLikelihood=sum(Obs.*log(IntensityPoisson)-IntensityPoisson);

% elseif strcmp(ModelParam.ModelObservation,'Normal')
%     %disp('Passe Likelihood Norma')
%     % Normal Observation
%     LogLikelihood=sum(-(1/(2*ModelParam.VarNoise))*(Obs-Mean).^2);
%     
% 
% end

