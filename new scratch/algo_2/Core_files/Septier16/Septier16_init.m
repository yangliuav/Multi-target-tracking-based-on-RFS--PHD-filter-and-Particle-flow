function [xp,m0,P0] = Septier16_init(ps, nParticle)
% Generates an initial particle distributions 
% according to a multivariate GH skewed-t distribution

% nu_init = initparams.stateDegreeFreedom;
% gamma_init = initparams.stateSkewness;
% Sigma_sqrt_init = initparams.stateCovarianceSR;

initparams = ps.initparams;

dimState = size(initparams.x0,1);

xp = zeros(dimState,nParticle);

switch initparams.init_dist
    case 'delta'
        m0 = initparams.x0;
        for particle_ix = 1:nParticle
            xp(:,particle_ix) = m0;
        end
end

P0 = initparams.initCov;