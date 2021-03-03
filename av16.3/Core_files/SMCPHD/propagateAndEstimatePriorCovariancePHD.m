function [vg,vgset,setup] = propagateAndEstimatePriorCovariancePHD(vg,vgset,setup,frm)
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
ps = setup.Ac;
tt = ps.propparams.time_step;
% Propagate the particles one step, without introducing dynamic noise.
propparams_no_noise = ps.propparams;
switch ps.example_name
    case 'Visual'
        propparams_no_noise.Q = 0*ps.propparams.Q(1:4,1:4);
        propparams_no_noise.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Q   = ps.propparams.Q(1:4,1:4);
    case 'Real_Data'
        propparams_no_noise.Q = 0*ps.propparams.Q(1:4,1:4);
        propparams_no_noise.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Q   = ps.propparams.Q(1:4,1:4);
    case 'Acoustic'
%         propparams_no_noise.Q = 0*ps.propparams.Q;
%         propparams_no_noise.Phi = ps.propparams.Phi;
        
        propparams_no_noise.Q = 0*ps.propparams.Q(1:4,1:4);
        propparams_no_noise.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Q   = ps.propparams.Q(1:4,1:4);
    case 'Septier16'
        propparams_no_noise.W = 0;
    case 'Locata'
        propparams_no_noise.Q = 0*ps.propparams.Q(1:4,1:4);
        propparams_no_noise.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Phi = ps.propparams.Phi(1:4,1:4);
        ps.propparams.Q   = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1]*0.1;
    otherwise
        error('The example name does not matche the record');
end

%%

for i = 1:size(vgset,2)
    vgset(i).mu_0 = ps.propparams.propagatefcn(vgset(i).M,propparams_no_noise);
    vgset(i).xp_prop_deterministic = ps.propparams.propagatefcn(vgset(i).xp,propparams_no_noise);
    vgset(i).xp_prop = ps.propparams.Phi *vgset(i).xp;%ps.propparams.propagatefcn(vgset(i).xp,ps.propparams);
    vgset(i).xp_prev = vgset(i).xp;
    vgset(i).xp = vgset(i).xp_prop;
    [vgset(i).M_prior,vgset(i).PP] = ukf_predict1(vgset(i).M,vgset(i).PU,@propparams_no_noise.propagatefcn,ps.propparams.Q(1:4,1:4),propparams_no_noise);
    vgset(i).w = setup.PHD.P_survival*vgset(i).w;
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
setup.Ac = ps;

if setup.out.print_frame 
    cmap = hsv(7);  %# Creates a 6-by-3 set of colors from the HSV colormap
    set(gcf);clf('reset');hold on;
    imshow(frm);
    drawnow;
%     figure(20);clf;hold on;
     %set(gcf, 'Position', [100, 100, 1000, 900]);
%         load 'sensorsXY';
%     fontsize = 24;
    ct = 0;
    if isfield(setup.inp,'x_all') %% plot Ground Truth
        xx = cell2mat(setup.inp.x_all);% groundtruth 
        xxt  =xx(:,tt);
        for i = 1: setup.Ac.nspeaker
            x_pos_i = xxt((i-1)*4+1,:);
            y_pos_i = xxt((i-1)*4+2,:);
            x_pos_i(x_pos_i==0) = NaN;
            y_pos_i(y_pos_i==0) = NaN;
            hold on;
            if ~isnan(x_pos_i) && ~isnan(y_pos_i)
                plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',5,'MarkerSize',20);  %# Plot each column with a
                ct=ct+1;
            end
        end
    end

    for i = 1: size(vgset,2)% plot particles
        if ct==0
            break;
        end
        x_pos_i = vgset(i).xp(1,:)
        y_pos_i = vgset(i).xp(2,:)
        hold on;
        if x_pos_i>=0 && y_pos_i>=0
            plot(x_pos_i(1),y_pos_i(1),'o','Color',[0,1,1],'LineWidth',3,'MarkerSize',3);  %# Plot each column with a %1-1*vgset(i).w/max(particle_weight)
        end
    end

    grid on;
%     axis(setup.Ac.likeparams.survRegion([1,3,2,4]))
%     set(gca,'xtick',0:10:setup.Ac.initparams.survRegion(3),'ytick',0:10:setup.Ac.initparams.survRegion(4),'FontSize',fontsize);
%     set(gcf,'color','w');
%     xlabel('X (m)','FontSize',fontsize);
%     ylabel('Y (m)','FontSize',fontsize);


    path = ['./result/',num2str(setup.trial_ix)];
    switch setup.pf_type
        case 'ZPF'
            path = [path, '/ZPF/'];
            title(['Particles of ZPF-SMC-PHD filter after predicting and birthing at k = ',num2str(tt)],'FontSize',8);
         case 'NPFS'
            path = [path, '/NPFS/'];
            title(['Particles of NPF-SMC-PHD_S filter after predicting and birthing at k = ',num2str(tt)],'FontSize',8);
        case 'NPF'
            path = [path, '/NPF/'];
            title(['Particles of NPF-SMC-PHD filter after predicting and birthing at k = ',num2str(tt)],'FontSize',8);
        case 'SMC'
            path = [path, '/SMC/'];
            title(['Particles of SMC-PHD filter filter after predicting and birthing at k = ',num2str(tt)],'FontSize',8);
        case 'IPF'
            path = [path, '/IPF/'];
            title(['Particles of IPF-SMC-PHD filter filter after predicting and birthing at k = ',num2str(tt)],'FontSize',8);
    end 
    path = [path, int2str(tt),'_a','.png'];
    print(gcf,'-painters','-dpng',path);
end
end