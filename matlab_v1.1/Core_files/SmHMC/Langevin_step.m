function vg = correctoinAndCalculateWeights(vg,ps,z_current,log_jacobian_det_sum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the importance weights and perform resampling if necessary
%
% Inputs:
% vg: a struct that contains the filter output
% ps: structure with filter and simulation parameters
% z_current: a column vector of the measurements at the current time step.
% log_jacobian_det_sum: the sum of the log of Jacobians used to update
% importance weights
%
% Output:
% vg: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

log_proposal = log_proposal_density(vg,ps,log_jacobian_det_sum);

log_prior = log_process_density(vg,ps);

llh = ps.likeparams.llh(vg.xp,z_current,ps.likeparams);

vg.logW = log_prior + llh - log_proposal + vg.logW;
vg.logW = vg.logW - max(vg.logW);

% Calculate the mean based on the updated particle weights
vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % form state estimate
vg.xp_m_unweighted = particle_estimate(zeros(size(vg.logW)),vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate 

if ps.setup.correct_mean
    vg.M = vg.xp_m; % copy the particle mean to the Kalman filter mean
end

%% resample based on the weights and also add regularized noise.
vg = resampleRegularize(vg,ps);
end