function xp_new = Septier16_propagate(xp,prop_params)

nu = prop_params.stateDegreeFreedom;
gamma = prop_params.stateSkewness;
Sigma_sqrt = prop_params.stateCovarianceSR;
dimState = size(xp,1);
nParticle = size(xp,2);

sample_new_gamma_variable = (~isfield(prop_params,'W') || prop_params.W~=0);

if sample_new_gamma_variable
    W = 1./gamrnd(nu/2,1/(nu/2),1,nParticle);
else
    W = zeros(1,nParticle);
end

xp_new = prop_params.transitionMatrix*xp+gamma*W+bsxfun(@times,sqrt(W),Sigma_sqrt*randn(dimState,nParticle));

end