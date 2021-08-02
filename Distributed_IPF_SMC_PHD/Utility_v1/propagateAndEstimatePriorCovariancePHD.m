function [vg,vgset,args] = propagateAndEstimatePriorCovariancePHD(sensor,args)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sample particles from the prior distribution, and generate particles that
% are independent of the sampling process to calculate the flow parameters.
%
% Input:
% vg: a struct that contains the filter output
% vg: particles set
% args: setup
%
% Output:
% vg: a struct that contains the filter output
% vg: particles set
% args: setup 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps = args.Example;
vg = sensor.vg;
vgset = sensor.vgset;
idxSensor = sensor.idx;
tt = ps.propparams.time_step;

% Propagate the particles one step, without introducing dynamic noise.
propparams_no_noise = ps.propparams;
propparams_no_noise.Q = 0*ps.propparams.Q(1:4,1:4);
propparams_no_noise.Phi = ps.propparams.Phi(1:4,1:4);
ps.propparams.Phi = ps.propparams.Phi(1:4,1:4);
ps.propparams.Q   = ps.propparams.Q(1:4,1:4);


%%

for i = 1:size(vgset,2)
    vgset(i).mu_0 = ps.propparams.propagatefcn(vgset(i).M,propparams_no_noise);
    vgset(i).xp_prop_deterministic = ps.propparams.propagatefcn(vgset(i).xp,propparams_no_noise);
    vgset(i).xp_prop = ps.propparams.Phi *vgset(i).xp;%ps.propparams.propagatefcn(vgset(i).xp,ps.propparams);
    vgset(i).xp_prev = vgset(i).xp;
    vgset(i).xp = vgset(i).xp_prop;
    [vgset(i).M_prior,vgset(i).PP] = ukf_predict1(vgset(i).M,vgset(i).PU,@propparams_no_noise.propagatefcn,ps.propparams.Q(1:4,1:4),propparams_no_noise);
    vgset(i).w = args.PHD.P_survival*vgset(i).w; % particle weights update first based on survival probability
end
% %% (Set the measurement noise covariance,) estimate the prior covariance
% 
% vg.mu_0 = ps.propparams.propagatefcn(vg.M,propparams_no_noise);
% 
% %ps = updateMeasurementCov(vg.M,ps);
% 
% % Run one step of the e/u Kalman filter to generate the estimated
% % covariance matrix
% 
% [vg.M_prior,vg.PP] = ukf_predict1(vg.M,vg.PU,@propparams_no_noise.propagatefcn,ps.propparams.Q,propparams_no_noise);
% 
% 
% %% propagate particles using dynamic models w/wo process noise
% vg.xp_prop_deterministic = ps.propparams.propagatefcn(vg.xp,propparams_no_noise);
% vg.xp_prop = ps.propparams.propagatefcn(vg.xp,ps.propparams);
% 
% switch ps.setup.pf_type
%     case 'EDH'
%         vg.xp_auxiliary_individual = mean(vg.xp_prop_deterministic,2);
%     case {'LEDH','LEDH_cluster'}
%         vg.xp_auxiliary_individual = vg.xp_prop_deterministic;
%     case 'None'
% end
% 
% 
%    
% vg.xp_prev = vg.xp;
% % forms a state estimate from the particles
% vg.xp = vg.xp_prop;
% vg.xp_m = particle_estimate(vg.logW,vg.xp,setup.maxilikeSAP,setup.maxilikemode);
% 
% if setup.out.plot_particles
%     ps.x = setup.x;
%     ps.setup.fontSize = 20;
%     ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'Prior');
% end
%sensor.vgset = vgset;
args.Example = ps;
args.inp.title_flag = 'propAndEsti'
if args.out.print_frame
   plotting(args,idxSensor,vgset) 
end


end