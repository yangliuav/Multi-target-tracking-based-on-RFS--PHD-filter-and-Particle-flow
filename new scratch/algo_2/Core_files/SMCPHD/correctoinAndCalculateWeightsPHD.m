function vgset = correctoinAndCalculateWeightsPHD(vgset,setup,z_current)
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
% 
% log_proposal = log_proposal_density(vg,ps,log_jacobian_det_sum);
% 
% log_prior = log_process_density(vg,ps);
% 
% llh = ps.likeparams.llh(vg.xp,z_current,ps.likeparams);
% 
% vg.logW = log_prior + llh - log_proposal + vg.logW;
% vg.logW = vg.logW - max(vg.logW);
% 
% % Calculate the mean based on the updated particle weights
% vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % form state estimate
% 
% % copy the particle mean to the Kalman filter mean
% vg.M = vg.xp_m;

% Run one step of the e/u Kalman filter to generate the estimated
% covariance matrix
ps  = setup.Ac;
for i = 1:size(vgset,2)
    switch setup.kflag
        case 'EKF1'  % single-order EKF
            [~,vg.PU] = ekf_update1(vgset(i).M_prior,vgset(i).PP,z_current,ps.likeparams.dh_dx_func,ps.likeparams.R,ps.likeparams.h_func,[],ps.likeparams);
        case 'UKF1'
            [~,vg.PU] = ukf_update1(vg.M_prior,vg.PP,z_current,ps.likeparams.h_func,ps.likeparams.R,ps.likeparams); 
        case 'none'
            % copy the particle mean and sample covariance to the Kalman filter mean
            weights = exp(vg.logW);
            weights = weights/sum(weights);
            de_mean = bsxfun(@minus, vg.xp, vg.xp_m);
            vg.PU = (bsxfun(@times,weights,de_mean))*de_mean'/(1-sum(weights.^2));
    end
    [~,regind] = chol(vg.PU);
    if regind
        vg.PU = cov_regularize(vg.PU);
    end
end





% Regularize the covariance matrix if necessary


% % resample based on the weights and also add regularized noise.
% vg = resampleRegularize(vg,ps);

end