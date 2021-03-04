function [output,position] = SMCPHD(setup,z, video,Z_doa)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement the Particle flow particle filter.
%
% Inputs:
% setup: structure with filter and simulation parameters
% z: each column corresponds to one time-step of the measurements
%
% Output:
% output: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic

[vg,vgset,output] = initializationFilterPHD(setup); % first appear
position = cell(size(z,2),1);
output.vgsetx = [];
output.vgsetw = [];
output.Nvgset = zeros(1,size(z,2));
output.speakerx = [];
output.Nspeakerx = zeros(1,size(z,2));
output.timecost = zeros(1,size(z,2));
output.OSPA = zeros(1,size(z,2));
clutter = 0.0035;
for tt = 1:size(z,2)%%  test frame setting
    set(gcf);clf('reset')
    frm = read(video,tt);
    %imshow(frm);
    %hold on;
    setup.Ac.propparams.time_step = tt;
    if isfield(setup.inp,'H_all')
        H  = setup.inp.H_all{tt}.h;
        vgset = SpawnAndBirthParticleWithMeasurement(setup,vgset,cell2mat(z(tt)),H);
    else
        vgset = SpawnAndBirthParticle(setup,vgset,tt,Z_doa); % add tt(framenumber) matrix Q cannot work well  
        H= [];
    end
    %%% propagate particles using prior and estimate the prior covariance matrix for particle flow filters.
    tic;
    [vg,vgset,setup] = propagateAndEstimatePriorCovariancePHD(vg,vgset,setup,frm);

 
    [vgset,setup] = posteriorPHD(vgset,setup,z(:,tt),H,clutter,frm);
    
    sumw = 0;
    sumw2 = 0;
    for i = 1:size(vgset,2)
        sumw = sumw + vgset(i).w;
        sumw2 = sumw2 + (vgset(i).w)*(vgset(i).w);
    end
    
    particle_state = zeros(4,size(vgset,2));
    particle_weight = zeros(1,size(vgset,2));
    particle_wlik = zeros(size(vgset,2),size(cell2mat(z(:,tt)),2));
    for i = 1:size(vgset,2)
        particle_state(:,i) = vgset(i).xp;
        particle_weight(:,i) = vgset(i).w; 
        for j = 1:size(cell2mat(z(:,tt)),2)
            particle_wlik(i,j) = vgset(i).wlik(j);
        end
    end
    %Tno=round(sumw);
    sumw
    inx = particle_weight>0.002;
    sum(particle_weight(inx))
    Tno=round(sum(particle_weight(inx)));
    %speakerx = [];
    if Tno ~= 0
        speakerx1 = cluster(particle_state(:,inx),Tno);
        %speakerx2 = clusterMEAP(particle_state(:,inx),particle_weight(:,inx),particle_wlik(inx,:),Tno);
        speakerx  = speakerx1(1:2,:);
        ESS(tt) =  sumw*sumw/sumw2;


        if isfield(setup.inp,'x_all')
            xx = cell2mat(setup.inp.x_all);
            xxt  =xx(:,tt);
            for i = 1:size(xxt,1)/4
               truex([1,2],i) = xxt([(i-1)*4+1,(i-1)*4+2],1);
            end  
        end

        if setup.out.print_frame 
            cmap = hsv(7);  %# Creates a 6-by-3 set of colors from the HSV colormap
%             figure(20);clf;hold on;
%             set(gcf, 'Position', [100, 100, 1000, 900]);
%                 load 'sensorsXY';
            set(gcf);clf('reset');hold on;
            imshow(frm)
            drawnow;
            fontsize = 24;
            ct = 0;
            if isfield(setup.inp,'x_all') % GT
                for i = 1: setup.Ac.nspeaker
                    x_pos_i = xxt((i-1)*4+1,:);
                    y_pos_i = xxt((i-1)*4+2,:);
                    x_pos_i(x_pos_i==0) = NaN;
                    y_pos_i(y_pos_i==0) = NaN;
                    hold on;
                    if ~isnan(x_pos_i) && ~isnan(y_pos_i)
                        plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',5,'MarkerSize',5);  %# Plot each column with a
                        ct = ct+1;
                    end
                end

            end

            for i = 1: size(vgset,2)
                if ct ==0
                    break;
                end
                x_pos_i = vgset(i).xp(1,:);
                y_pos_i = vgset(i).xp(2,:);
                hold on;
                if x_pos_i>=0 && y_pos_i>=0 
                    plot(x_pos_i(1),y_pos_i(1),'o','Color',[1,1,1-1*vgset(i).w/max(particle_weight)],'LineWidth',3,'MarkerSize',10);  %# Plot each column with a %1-1*vgset(i).w/max(particle_weight)
                end
            end
            for i = 1: size(speakerx,2)
                if ct ==0
                    break;
                end;
                x_pos_i = speakerx(1,i);
                y_pos_i = speakerx(2,i);
                hold on;
                if x_pos_i>=0 && y_pos_i>=0 
                    plot(x_pos_i(1),y_pos_i(1),'p','Color',cmap(7,:),'LineWidth',3,'MarkerSize',7);  %# Plot each column with a
                end
            end

    %        h_leg=legend('Sensor','Target 1','Target 2','Target 3','Target 4','starting position');
    %        set(h_leg,'FontSize',fontsize,'Location','southeast');

            grid on;
% 
%             axis(setup.Ac.likeparams.survRegion([1,3,2,4]))
%             set(gca,'xtick',0:10:setup.Ac.initparams.survRegion(3),'ytick',0:10:setup.Ac.initparams.survRegion(4),'FontSize',fontsize);
            set(gcf,'color','w');
%             xlabel('X (m)','FontSize',fontsize);
%             ylabel('Y (m)','FontSize',fontsize);


            path = ['./result/',num2str(setup.trial_ix)];
            switch setup.pf_type
                case 'ZPF'
                    path = [path, '/ZPF/'];
                    title(['Particles of ZPF-SMC-PHD filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
                case 'IPF'
                    path = [path, '/IPF/'];
                    title(['Particles of ZPF-SMC-PHD filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
                case 'NPF'
                    path = [path, '/NPF/'];
                    title(['Particles of NPF-SMC-PHD filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
                case 'NPFS'
                    path = [path, '/NPFS/'];
                    title(['Particles of NPF-SMC-PHD_S filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
                case 'SMC'
                    path = [path, '/SMC/'];
                    title(['Particles of SMC-PHD filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
            end  
            path = [path, int2str(tt),'_b','.png'];
            print(gcf,'-painters','-dpng','-r600',path);
        end    








        if ESS(tt) < 0.5*Tno*50
            Lk                  =   min(round(Tno*50),200);
            idx                 =   my_resample(particle_weight(1,:)'/sumw,Lk);
            particle_state_resample   =   particle_state(:,idx);
            particle_state            =   particle_state_resample; 
            particle_weight           =   particle_weight(:,idx);
            particle_wlik             =   particle_wlik(idx,:);
            particle_weight          = Tno* particle_weight/sum(particle_weight);
            vgset = {};
            for i = 1:size(particle_state,2)
                vgset(i).xp = particle_state(:,i);
                vgset(i).PP = zeros(4,4);
                vgset(i).PU = blkdiag(100,100,1,1);
                vgset(i).M  = vgset(i).xp;
                vgset(i).xp_m = vgset(i).xp;
                vgset(i).w  = particle_weight(:,i);
                vgset(i).PD = 1; % remove later
            end
            %speakerx3 = clusterMEAP(particle_state,particle_weight,particle_wlik,Tno);
        else
            [w,del]=sort(-particle_weight);
            Ndel = size(del,2) - Tno*50;
            if Ndel >0
                vgset(del(size(del,2):-1:size(del,2)-Ndel+1))= [];
            end
        end

        toc;
        output.timecost(tt) = toc;

        if setup.out.print_frame
            cmap = hsv(7);  %# Creates a 6-by-3 set of colors from the HSV colormap
%             figure(20);clf;hold on;
%             set(gcf, 'Position', [100, 100, 1000, 900]);
%                 load 'sensorsXY';
            set(gcf);clf('reset');hold on;
            imshow(frm);
            drawnow;
            fontsize = 24;
            ct=0;
            if isfield(setup.inp,'x_all')
                xx = cell2mat(setup.inp.x_all);
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
                for i = 1:size(xxt,1)/4
                    truex([1,2],i) = xxt([(i-1)*4+1,(i-1)*4+2],1);
                end
            end

            for i = 1: size(vgset,2)
                if ct==0
                    break;
                end
                x_pos_i = vgset(i).xp(1,:);
                y_pos_i = vgset(i).xp(2,:);
                hold on;
                if x_pos_i>=0 && y_pos_i>=0 
                    plot(x_pos_i(1),y_pos_i(1),'o','Color',[0,1,1],'LineWidth',3,'MarkerSize',10);  %# Plot each column with a %1-1*vgset(i).w/max(particle_weight)
                end
            end
            for i = 1: size(speakerx,2)
                if ct==0
                    break;
                end
                x_pos_i = speakerx(1,i);
                y_pos_i = speakerx(2,i);
                hold on;
                if x_pos_i>=0 && y_pos_i>=0 
                    plot(x_pos_i(1),y_pos_i(1),'p','Color',cmap(7,:),'LineWidth',3,'MarkerSize',30);  %# Plot each column with a
                end
            end

    %        h_leg=legend('Sensor','Target 1','Target 2','Target 3','Target 4','starting position');
    %        set(h_leg,'FontSize',fontsize,'Location','southeast');

            grid on;

%             axis(setup.Ac.likeparams.survRegion([1,3,2,4]))
%             set(gca,'xtick',0:10:setup.Ac.initparams.survRegion(3),'ytick',0:10:setup.Ac.initparams.survRegion(4),'FontSize',fontsize);
            set(gcf,'color','w');
%             xlabel('X (m)','FontSize',fontsize);
%             ylabel('Y (m)','FontSize',fontsize);


            path = ['./result/',num2str(setup.trial_ix)];
            switch setup.pf_type
                case 'ZPF'
                    path = [path, '/ZPF/'];
                    title(['Estimated taregts and resampled or clipped particles at k = ',num2str(tt)],'FontSize',8);
                case 'IPF'
                    path = [path, '/IPF/'];
                    title(['Estimated taregts and resampled or clipped particles at k = ',num2str(tt)],'FontSize',8);
                case 'NPF'
                    path = [path, '/NPF/'];
                    title(['Estimated taregts and resampled or clipped particles at k = ',num2str(tt)],'FontSize',8);
                case 'NPFS'
                    path = [path, '/NPFS/'];
                    title(['Particles of NPF-SMC-PHD_S filter before resampling and clipping at k = ',num2str(tt)],'FontSize',8);
                case 'SMC'
                    path = [path, '/SMC/'];
                    title(['Estimated taregts and resampled or clipped particles at k = ',num2str(tt)],'FontSize',8);
            end 
            path = [path, int2str(tt),'_c','.png'];
            print(gcf,'-painters','-dpng',path);
        end
    else
        vgset = vgset(inx);
    end
    %% store the effective number of each time step.
   
    output.vgsetx = [output.vgsetx,vgset.xp];
    output.vgsetw = [output.vgsetw,vgset.w];
    output.Nvgset(tt) = size(vgset,2); 
    output.speakerx = [output.speakerx,speakerx];
    output.Nspeakerx(tt) = size(speakerx,2); 
    position{tt} =  num2cell(speakerx);
    if exist('truex','var')
        output.OSPA(tt) = ospa_dist(speakerx,truex,setup.ospa_c,setup.ospa_p);
        disp(['OSPA = ',num2str( output.OSPA(tt))]);
    end
    %disp(['Number of target = ',num2str( output.Nspeakerx(tt))]);
    
    clutter = 0.0365;
end

%calculateErrors(output,setup,setup.algs);
end