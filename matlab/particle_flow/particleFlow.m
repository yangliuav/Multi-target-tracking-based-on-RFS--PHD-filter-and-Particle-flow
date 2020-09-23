function vg = particleFlow(vg,vgset,setup,z_current)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function performs particle flow and resampling (if needed)
%
% Inputs:
% vg: a struct that contains the filter output
% ps: structure with filter and simulation parameters
% z_current: a column vector of the measurements at the current time step.
%
% Output:
% vg: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps = setup.Ac;
tt = ps.propparams.time_step;
lambda_prev = 0;
% jacobian_det_prod is calculated for PFPF (LEDH) weight update.
log_jacobian_det_sum = zeros(1,setup.nParticle);
for lambda = setup.lambda_range
    % Calculate the slopes used to migrate particles
    step_size = lambda-lambda_prev;
    
    %ps = updateMeasurementCov(vg.xp_auxiliary_individual,ps);

    [slope, log_jacobian_det] = calculateSlope(z_current,vg,ps,lambda,step_size);
    
    % Calculate the sum of the log Jacobian determinants used in weight update
    log_jacobian_det_sum = log_jacobian_det_sum + log_jacobian_det;
    log_jacobian_det_sum = log_jacobian_det_sum - max(log_jacobian_det_sum);
    
    % if we only perform clustering before the flow,
    % there is no need to update vg.xp_auxiliary_individual
    if ps.setup.use_cluster
        vg.xp_auxiliary_cluster = vg.xp_auxiliary_cluster + step_size*slope.auxiliary_cluster;
    else
        vg.xp_auxiliary_individual = vg.xp_auxiliary_individual + step_size*slope.auxiliary_individual;
    end

    vg.xp = vg.xp + step_size*slope.real;  % Euler update of particles
    
    vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate 
    lambda_prev = lambda;
        
    if ps.setup.doplot
        pause(0.1);
        ps.setup.plotfcn(vg,ps,slope.real,tt,['particle flow, \lambda = ',num2str(round(1e3*lambda_prev)*1e-3)]); % call plot function  
    end
end

%% Add a noise to the auxiliary variables and then evaluate the weights.
vg = correctoinAndCalculateWeights(vg,ps,z_current,log_jacobian_det_sum);
end