function z = Septier16_hfunc(xp , likeparams)
% measurement function for the poisson mean
%
% Inputs:
% xp: state value
%  
% likeparams: a structure containing the field 'ObservationTransition',
%             'MappingIntensityCoeff','MappingIntensityScale'.
%
% Output:
%
%  z = MappingIntensityCoeff*exp(xp/MappingIntensityScale)
%%%%%%%%%%%%%%%%%%%%%%%

m1 = likeparams.mappingIntensityCoeff;
m2 = likeparams.mappingIntensityScale;
alpha = likeparams.observationTransition;

z = m1*exp(alpha*xp/m2);