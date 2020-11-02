function dhdx = Septier16_dh_dxfunc(xp , likeparams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Derivative of measurement function for the poisson mean used in the
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

m1 = likeparams.mappingIntensityCoeff;
m2 = likeparams.mappingIntensityScale;
alpha = likeparams.observationTransition;

if nParticle > 1
    dhdx = zeros(dim,dim,nParticle);
    nnz_entries = repmat(eye(dim),1,1,nParticle);
    dhdx_diag = alpha'*m1*exp(alpha*xp/m2)/m2;
    dhdx(nnz_entries==1) = dhdx_diag(:);
else
    dhdx = alpha'*diag(m1*exp(alpha*xp(:)/m2)/m2);
end