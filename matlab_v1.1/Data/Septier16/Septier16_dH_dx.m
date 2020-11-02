function dH_dx = Septier16_dH_dx(xp, likeparams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hessian of measurement function for the poisson mean used in the
% "Septier16" example.
%
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
%  dhdx = MappingIntensityCoeff*exp(xp/MappingIntensityScale)/MappingIntensityScale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dim,nParticle] = size(xp);

if nParticle > 1
    error('This function is only defined for a single state')
end

m1 = likeparams.mappingIntensityCoeff;
m2 = likeparams.mappingIntensityScale;
alpha = likeparams.observationTransition;

dH_dx = zeros(dim,dim,dim);

% non-zero Hessian only exists for the same state dimension and
% measurement dimension, so we first calculate Hessian and store in a
% vector.
dH_dx_one_dimension = alpha*m1*exp(alpha*xp(:)/m2)/m2^2;

for ix = 1:dim
    dH_dx(ix,ix,ix) = dH_dx_one_dimension(ix);
end