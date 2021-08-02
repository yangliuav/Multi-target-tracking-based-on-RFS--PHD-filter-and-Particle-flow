function xp = Propagate(xp,prop_params)
% This function implements proposed IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
%
% Inputs:
% xp: particles state
% prop_params: parameters for propagtate
%     
% Outputs:
% xp: propagated particles state

[dim,nParticles] = size(xp);

Phi = prop_params.Phi;
multiGamma = prop_params.Q;

xp = mvnrnd((Phi*xp)',multiGamma)';
end

