function [output] = DH_ExactFlow_Filter(ps,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The implementation of the Daum-Huang exact flow particle filter.
% The codes follow the implementation of the algorithms described in
% T. Ding and M. J. Coates, “Implementation of the daum-huang exactflow
%         particle filter,” in Proc. IEEE Statistical Signal Processing Workshop
%         (SSP), Ann Arbor, MI, Aug. 2012, pp. 257–260.
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
    if tt~=1 && ps.setup.Redraw
        vg.xp = bsxfun(@plus,sqrtm(vg.PU)*randn(ps.setup.dimState_all,ps.setup.nParticle),vg.xp_m); % Redraw if desired
    end

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
   
    switch ps.setup.kflag
        case 'EKF1'  % single-order EKF
            [vg.M_prior,vg.PP] = ekf_predict1(vg.M,vg.PU,[],ps.propparams.Q,@propparams_no_noise.propagatefcn,[],propparams_no_noise);
        case 'UKF1'
            % NOT TESTED FOR THIS RELEASE
            [vg.M_prior,vg.PP] = ukf_predict1(vg.M,vg.PU,@propparams_no_noise.propagatefcn,ps.propparams.Q,propparams_no_noise);
        case 'none'
            xp_tmp = ps.propparams.propagatefcn(vg.xp,ps.propparams);
            vg.M_prior = mean(xp_tmp,2);
            vg.PP = cov(xp_tmp');
    end     

    logW = log(ones(1,ps.setup.nParticle)/ps.setup.nParticle);
    
    if ps.setup.doplot
        ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'before propagation');
    end
    
    %% prior propagation
    vg.xp = ps.propparams.propagatefcn(vg.xp,ps.propparams);   

    switch ps.setup.kflag
        case 'none'
            vg.PP = cov(vg.xp');
    end
    
    % Form a state estimate from the particles 
    vg.xp_m = particle_estimate(logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode);
    vg.mu_0 = vg.xp_m;
    
    if ps.setup.doplot
        ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'after prior propagation');
    end
    
    %% Step through the lambda 
    lambda_prev = 0;
    for lambda = ps.setup.lambda_range
        switch ps.setup.pf_type
            case {'LEDH_cluster','LEDH'}
                ps = updateMeasurementCov(vg.xp,ps);
            case 'EDH'
                ps = updateMeasurementCov(vg.xp_m,ps);
        end
        
        step_size = lambda-lambda_prev;

        % Calculate the slopes for moving the particles       
        slope_struct = calculateSlope(z(:,tt),vg,ps,lambda,step_size);
        slope = slope_struct.real;
        
        if ps.setup.doplot 
            ps.setup.plotfcn(vg,ps,slope,tt,['in the process of particle flow, lambda = ',num2str(lambda)]); % call plot function  
        end
        
        vg.xp = vg.xp + step_size*slope;  % euler update of particles        
        vg.xp_m = particle_estimate(logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate         
        lambda_prev = lambda;
    end
    
    if ps.setup.doplot
        ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'after particle flow'); % call plot function  
    end
    
    % Calculate the mean based on the updated particle weights
    vg.xp_m = particle_estimate(logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % form state estimate
    
    vg.M = vg.xp_m; % copy the particle mean to the Kalman filter mean
    
    ps = updateMeasurementCov(vg.M,ps);
    switch ps.setup.kflag
        case 'EKF1'  % single-order EKF
            [~,vg.PU] = ekf_update1(vg.M_prior,vg.PP,z(:,tt),ps.likeparams.dh_dx_func,ps.likeparams.R,ps.likeparams.h_func,[],ps.likeparams);
        case 'UKF1'
            [~,vg.PU] = ukf_update1(vg.M_prior,vg.PP,z(:,tt),ps.likeparams.h_func,ps.likeparams.R,ps.likeparams); 
        case 'none'
            vg.PU = cov(vg.xp');
    end
    
    % Regularize the Kalman covariance matrix if necessary
    [~,regind] = chol(vg.PU);
    if regind
        vg.PU = cov_regularize(vg.PU);
    end; 
    
    output.x_est(:,tt) = vg.xp_m;
end

output.x = ps.x;
output.execution_time = toc;
alg_name = ps.setup.pf_type;
calculateErrors(output,ps,alg_name);
end