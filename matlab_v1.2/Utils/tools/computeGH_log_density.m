function log_density = computeGH_log_density(xp,mu,propparams)

nu = propparams.stateDegreeFreedom;
% lambda = propparams.lambda;
% ksi = propparams.ksi;
gamma = propparams.stateSkewness;
stateCovarianceInv = propparams.stateCovarianceInv;
% psi = 0;
dim = size(xp,1);
nParticle = size(xp,2);

Diff_normalized = (xp - mu)'*stateCovarianceInv;
Qxn = Diff_normalized*(xp - mu);

log_density = zeros(1,nParticle);
for particle_ix = 1:nParticle
    Z = sqrt((nu+Qxn(particle_ix,particle_ix))*(gamma'*stateCovarianceInv*gamma));
    log_density(particle_ix) = log(besselk((nu+dim)/2,Z))...
        +Diff_normalized(particle_ix,:)*gamma...
        +(nu+dim)/2*log(Z)...
         -(nu+dim)/2*log(1+Qxn(particle_ix,particle_ix)/nu);
%         +log(Z)*(lambda-dim/2);
end
end