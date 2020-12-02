function [vg,ps] = propagateAndEstimatePriorCovariance(vg,ps,z_current)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sample particles from the prior distribution, and generate particles that
% are independent of the sampling process to calculate the flow parameters.
%
% Input:
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
% z_current: a column vector of the measurements at the current time step
%
% Output:
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tt = ps.propparams.time_step;

% Propagate the particles one step, without introducing dynamic noise.
propparams_no_noise = ps.propparams;
switch ps.setup.example_name
    case 'Acoustic'
        propparams_no_noise.Q = 0*ps.propparams.Q;
    case 'Septier16'
        propparams_no_noise.W = 0;
    otherwise
        error('The example name does not matche the record');
end

%% (Set the measurement noise covariance,) estimate the prior covariance
vg.mu_0 = ps.propparams.propagatefcn(vg.M,propparams_no_noise);

ps = updateMeasurementCov(vg.M,ps);

% Run one step of the e/u Kalman filter to generate the estimated
% covariance matrix
switch ps.setup.kflag
    case 'UKF1'
        [vg.M_prior,vg.PP] = ukf_predict1(vg.M,vg.PU,@propparams_no_noise.propagatefcn,ps.propparams.Q,propparams_no_noise);
    otherwise% single-order EKF
        [vg.M_prior,vg.PP] = ekf_predict1(vg.M,vg.PU,[],ps.propparams.Q,@propparams_no_noise.propagatefcn,[],propparams_no_noise);
end

%% propagate particles using dynamic models w/wo process noise
vg.xp_prop_deterministic = ps.propparams.propagatefcn(vg.xp,propparams_no_noise);
vg.xp_prop = ps.propparams.propagatefcn(vg.xp,ps.propparams);

switch ps.setup.pf_type
    case 'EDH'
        vg.xp_auxiliary_individual = mean(vg.xp_prop_deterministic,2);
    case {'LEDH','LEDH_cluster'}
        vg.xp_auxiliary_individual = vg.xp_prop_deterministic;
end

if ps.setup.use_cluster && strcmp(ps.setup.pf_type,'LEDH_cluster')
   vg = perform_clustering(z_current,vg,ps,ps.setup.lambda_range(1));
end
   
vg.xp_prev = vg.xp;
% forms a state estimate from the particles
vg.xp = vg.xp_prop;
vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode);

if ps.setup.doplot
    ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'Prior');
end
end