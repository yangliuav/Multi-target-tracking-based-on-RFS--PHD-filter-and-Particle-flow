function vgset = particleFlowPHD(vgset,setup,z_current,Cz)
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
H = [1,0,0,0;0,1,0,0]';
% h = inp.H;
lm = zeros(1,size(vgset,2));
for i = 1:size(vgset,2)
    [~,lm(:,i)] = max(vgset(i).llh);
end
particle_state = zeros(4,size(vgset,2));
particle_weight = zeros(1,size(vgset,2));
mm = zeros(4,size(z_current,2));
PP = zeros(4,4,size(z_current,2));
t= 0;
vgsetpre = vgset;

for lambda = setup.lambda_range
    % Calculate the slopes used to migrate particles
    step_size = lambda-lambda_prev;
    t= t+1;
    %ps = updateMeasurementCov(vg.xp_auxiliary_individual,ps);
    if  size(vgset,1) ~= 0
        [slope, log_jacobian_det] = calculateSlopePHD(z_current,vgset,setup,lambda,step_size,Cz);
    end
    if max(abs(slope(:,1))) < 0.2 && lambda ~=0
        break;
    end
    for i = 1:size(vgset(),2)
        if size(slope(:,i),1)== 2
            vgset(i).xp = vgset(i).xp + step_size*H*slope(:,i);
%             a =  step_size*H*slope(:,i)
%             a = vgset(i).xp  
%             a = z_current
        else
            vgset(i).xp = vgset(i).xp + step_size*slope(:,i);  % Euler update of particles
%             a =  step_size*slope(:,i)
%             a = vgset(i).xp  
%             a = z_current
        end
        particle_state(:,i) = vgset(i).xp;
        particle_weight(:,i) = vgset(i).w;
    end
    
    
    for i = 1:size(z_current,2)
        Cz(:,i) = 0;
        for j = 1:size(vgset,2)
            switch setup.Ac.example_name
                case 'Acoustic'
                    vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z_current(:,i),setup.Ac.likeparams);
                case 'Septier16'       
                    [x,y] = generateSeptier16TrackMeasurements(setup);
                case 'Visual'
                    vgset(j).llh(:,i) =  VisualGaussian_llh_PHD(vgset(j).xp,z_current(:,i),setup.Ac.likeparams);
                case 'Locata'
                    vgset(j).llh(:,i) = interp2(h,vgset(j).xp(2),vgset(j).xp(1))*VisualGaussian_llh_PHD(vgset(j).xp,z_current(:,i),setup.Ac.likeparams);
                    a = vgset(j).llh(:,i);
                    if isnan(vgset(j).llh(:,i) ) 
                        vgset(j).llh(:,i) =0;
                    end
            end
            
            if(vgset(j).llh(:,i)>1)
                vgset(j).llh(:,i) =1;
            end
            Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w;
        end   
    end
    % Calculate the sum of the log Jacobian determinants used in weight update
%     log_jacobian_det_sum = log_jacobian_det_sum + log_jacobian_det;
%     log_jacobian_det_sum = log_jacobian_det_sum - max(log_jacobian_det_sum);
    
    % if we only perform clustering before the flow,
    % there is no need to update vg.xp_auxiliary_individual
%     vg.xp_auxiliary_individual = vg.xp_auxiliary_individual + step_size*slope.auxiliary_individual;

    
    %vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate 
    lambda_prev = lambda;
        
    
    if setup.out.print_frame 
           cmap = hsv(7);  %# Creates a 6-by-3 set of colors from the HSV colormap
            figure(20);clf;hold on;
            set(gcf, 'Position', [100, 100, 1000, 900]);
                load 'sensorsXY';
            fontsize = 24;
            if isfield(setup.inp,'x_all')
                xx = cell2mat(setup.inp.x_all);
                xxt  =xx(:,tt);
                for i = 1: setup.Ac.nspeaker
                    x_pos_i = xxt((i-1)*4+1,:);
                    y_pos_i = xxt((i-1)*4+2,:);
                    plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',5,'MarkerSize',20);  %# Plot each column with a
                end

            end

            if isfield(setup.inp,'c_all')
                cc = cell2mat(setup.inp.c_all);
                cct  =cc(:,tt);
                for i = 1:size(cct,1)/4
                    x_pos_i = cct((i-1)*4+1,:);
                    y_pos_i = cct((i-1)*4+2,:);
                    plot(x_pos_i(1),y_pos_i(1),'xk','Color',cmap(i+4,:),'LineWidth',3,'MarkerSize',30);  %# Plot each column with a
                end
            end

            for i = 1: size(vgset,2)
                x_pos_i = vgset(i).xp(1,:);
                y_pos_i = vgset(i).xp(2,:);
                plot(x_pos_i(1),y_pos_i(1),'o','Color',[1,1,0.5],'LineWidth',3,'MarkerSize',10);  %# Plot each column with a %1-1*vgset(i).w/max(particle_weight)
            end

    %        h_leg=legend('Sensor','Target 1','Target 2','Target 3','Target 4','starting position');
    %        set(h_leg,'FontSize',fontsize,'Location','southeast');

            grid on;

            axis(setup.Ac.likeparams.survRegion([1,3,2,4]))
            set(gca,'xtick',0:10:setup.Ac.initparams.survRegion(3),'ytick',0:10:setup.Ac.initparams.survRegion(4),'FontSize',fontsize);
            set(gcf,'color','w');
            xlabel('X (m)','FontSize',fontsize);
            ylabel('Y (m)','FontSize',fontsize);


            path = ['./result/',num2str(setup.trial_ix)];

        switch setup.pf_type
            case 'ZPF'
                path = [path, '/ZPF/'];
                title(['Particles of ZPF-SMC-PHD filter at k = ',num2str(tt),' and \lambda = ',num2str(lambda)],'FontSize',16);
            case 'NPF'
                path = [path, '/NPF/'];
                title(['Particles of NPF-SMC-PHD filter at k =',num2str(tt),' and \lambda = ',num2str(lambda)],'FontSize',16);
            case 'IPF'
                path = [path, '/IPF/'];
                title(['Particles of IPF-SMC-PHD filter at k =',num2str(tt),' and \lambda = ',num2str(lambda)],'FontSize',16);
            case 'NPFS'
                path = [path, '/NPFS/'];
                title(['Particles of NPF-SMC-PHD_S filter at k =',num2str(tt),' and \lambda = ',num2str(lambda)],'FontSize',16);
            case 'SMC'
                path = [path, '/SMC/'];
                title(['Particles of SMC-PHD filter at k =',num2str(tt),' and \lambda = ',num2str(lambda)],'FontSize',16);
        end
        path = [path, int2str(tt), '_',int2str(t),'.png'];
        print(gcf,'-painters','-dpng',path);
    end
%     if ps.setup.doplot
%         pause(0.1);
%         ps.setup.plotfcn(vg,ps,slope.real,tt,['particle flow, \lambda = ',num2str(round(1e3*lambda_prev)*1e-3)]); % call plot function  
%     end
end

for i = 1:size(vgset,2)
%     minu = bsxfun(@minus,vgset(i).xp,vgsetpre(i).xp);
%     m = minu(1)^2 + minu(2)^2;
%     m = m^(1/2);
%     w = sum(normpdf(m,0,10));
    vgset(i).w = vgset(i).w;
end
%% Add a noise to the auxiliary variables and then evaluate the weights.
%vgset = correctoinAndCalculateWeightsPHD(vgset,setup,z_current);
end