function [xp,logwt] = VisualPropagate(xp,prop_params)

[dim,nParticles] = size(xp);

Phi = prop_params.Phi;
multiGamma = prop_params.Q;
% numTargets = prop_params.numTargets;

xp = mvnrnd((Phi*xp)',multiGamma)';

% logwt is not used in this version - set it to a vector of ones.
logwt = ones(nParticles,1);

end

