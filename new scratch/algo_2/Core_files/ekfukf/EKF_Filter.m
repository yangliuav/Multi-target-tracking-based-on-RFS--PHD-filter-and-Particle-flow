function [output] = EKF_Filter(ps,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The execution of the extended Kalman filter.
%
% Input:
% ps: a struct that contains model parameters.
% z: a measurement_dim x T matrix
%
% Output:
% output: a struct that contains the filter outputs, including the particle
% estimate, true state, execution time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
T = ps.setup.T; % number of time steps

[vg,output] = initializationFilter(ps);

for tt = 1:T
    ps.propparams.time_step = tt;
    
    % Propagate the particles one step
    propparams_no_noise = ps.propparams;
    switch ps.setup.example_name
        case 'Acoustic'
            propparams_no_noise.Q = 0*ps.propparams.Q;
        case 'Septier16'
            propparams_no_noise.W = 0;
        otherwise
            error('The example name does not matche the record');
    end
    % Run one step of the e/u Kalman filter to generate the estimated
    % covariance matrix
    ps = updateMeasurementCov(vg.M,ps);
    
    [vg.M_prior,vg.PP] = ekf_predict1(vg.M,vg.PU,[],ps.propparams.Q,@propparams_no_noise.propagatefcn,[],propparams_no_noise);
    
    ps = updateMeasurementCov(vg.M_prior,ps);
    [vg.M,vg.PU] = ekf_update1(vg.M_prior,vg.PP,z(:,tt),ps.likeparams.dh_dx_func,ps.likeparams.R,ps.likeparams.h_func,[],ps.likeparams);

    % Regularize the Kalman covariance matrix if necessary
    [~,regind] = chol(vg.PU);
    if regind
        vg.PU = cov_regularize(vg.PU);
    end;      
     
    output.x_est(:,tt) = vg.M;
end

output.x = ps.x;
output.execution_time = toc;
alg_name = 'EKF';
calculateErrors(output,ps,alg_name);
end