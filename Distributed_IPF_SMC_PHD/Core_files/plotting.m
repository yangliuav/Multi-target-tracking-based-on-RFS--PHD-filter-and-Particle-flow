function [args] = plotting(args,idxSensor,varargin)
% This function draws output
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
%
% Input:
% args: setup
%
% Output:
% ps: a structure containg the simulation setup and filter parameters,
%     and all true trExampleks and observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if isfield(args.inp,'x_all')
    x = cell2mat(args.inp.x_all);
end

if isfield(args.inp,'y_all')
    y = cell2mat(args.inp.y_all{idxSensor});
end

if isfield(args.inp,'c_all')
    c = cell2mat(args.inp.x_all);
end
if isfield(args.Example.propparams,'time_step')
    tt = args.Example.propparams.time_step;
end

% check var size to read out the var input
if size(varargin,2) == 1
    vgset = cell2mat(varargin);
elseif size(varargin,2) == 2
    vgset = varargin{1};
    if size(varargin{2},2) == 1
        lambda = varargin{2};
    else
        args.inp.speakerx = varargin{2};
    end
end
%%
if args.inp.plot_flag == 'initial'
    figure(50);clf;hold on;
else
    figure(idxSensor);clf;hold on;
end
set(gcf, 'Position', [100, 100, 1000, 900]);
load 'sensorsXY';
fontsize = 24;
simAreaSize=args.inp.survRegion(3); %size of the area
axis(args.Example.likeparams.survRegion([1,3,2,4]))
set(gca,'xtick',0:10:40,'ytick',0:10:40,'FontSize',fontsize);
set(gcf,'color','w');
xlabel('X (m)','FontSize',fontsize);
ylabel('Y (m)','FontSize',fontsize);

    
file_path = args.root;

if args.inp.plot_flag == 'initial'
    dt = datestr(now,'yyyymmddHHMM')
    dt = [dt,'.png'];

    nTarget = size(x,1)/4;
    nClutter = size(c,1)/4;
    cmap = hsv(nTarget+3);  %# Creates a 6-by-3 set of colors from the HSV colormap
    
    % draw targets
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);
        plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',2,'MarkerSize',10);  %# Plot eExampleh column with a
    end
    % draw start point
    x_pos_i = [];
    y_pos_i = [];
    for i = 1:nTarget
        x_pos_i(i) = x((i-1)*4+1,1);
        y_pos_i(i) = x((i-1)*4+2,1);      
    end
    plot(x_pos_i,y_pos_i,'xk','LineWidth',3,'MarkerSize',30);  %# Plot eExampleh column with a
    % draw clutters
    x_pos_i = [];
    y_pos_i = [];
    for i = 1:nClutter
        for t = 1:size(c,2)
            x_pos_i(t+(size(c,2)-1)*i) = c((i-1)*4+1,t);
            y_pos_i(t+(size(c,2)-1)*i) = c((i-1)*4+2,t);
        end
    end
    plot(x_pos_i,y_pos_i,'ob','LineWidth',1,'MarkerSize',4);  %# Plot eExampleh column with a
    
    h_leg=legend('Target 1','Target 2','Target 3','Target 4','Starting position','Clutter','Undetected state');
    set(h_leg,'FontSize',7,'Location','southeast');
    title('Simulation Experiment Ground Truth','fontsize',16);
    grid on;
    print(gcf,'-painters','-dpng',fullfile(char(file_path),'result','Groundtrue',dt));
    args.inp.plot_flag = 2; % different to origin flag
else
    cmap = hsv(7);
    if isfield(args.inp,'x_all')
        xt = x(:,tt); % state at time t
        for i = 1:args.Example.nTarget
            x_pos_i = xt((i-1)*4+1,:);
            y_pos_i = xt((i-1)*4+2,:);
            plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',2,'MarkerSize',30);
        end
    end
    
    if isfield(args.inp,'c_all')
        ct = c(:,tt); % state at time t
        for i = 1:args.Example.nTarget
            x_pos_i = ct((i-1)*4+1,:);
            y_pos_i = ct((i-1)*4+2,:);
            plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',2,'MarkerSize',10);
        end
    end
    
    if isfield(args.inp,'speakerx')
        speakerx = args.inp.speakerx;
        for i = 1: size(speakerx,2)
                x_pos_i = speakerx(1,i);
                y_pos_i = speakerx(2,i);
                plot(x_pos_i(1),y_pos_i(1),'p','Color',cmap(7,:),'LineWidth',3,'MarkerSize',30);  %# Plot eExampleh column with a
        end
    end

    % plot particles
    for i = 1: size(vgset,2)
        x_pos_i = vgset(i).xp(1,:);
        y_pos_i = vgset(i).xp(2,:);
        plot(x_pos_i(1),y_pos_i(1),'o','Color',[0,1,1],'LineWidth',3,'MarkerSize',10);  %# Plot eExampleh column with a %1-1*vgset(i).w/max(particle_weight)
    end
    
    grid on;
    
    switch args.inp.title_flag
        case 'propAndEsti'
            pt = [strcat(num2str(tt),'_a'),'.png'];
            title(['Particles after predicting and birthing at k = ',num2str(tt), ' in Sensor =', num2str(idxSensor)],'FontSize',16);
            print(gcf,'-painters','-dpng',fullfile(char(file_path),'Result','Sensor',num2str(idxSensor),pt));
        case 'SMCPHD'
            pt = [strcat(num2str(tt)),'.png'];
            title(['Particles of IPF-SMC-PHD filter at k =',num2str(tt), ' in Sensor =', num2str(idxSensor)],'FontSize',16);
            print(gcf,'-painters','-dpng',fullfile(char(file_path),'Result','Sensor',num2str(idxSensor),pt));
        case 'bef_resamp'
            pt = [strcat(num2str(tt),'_b'),'.png'];
            title(['Particles of IPF-SMC-PHD filter before resampling and clipping at k = ',num2str(tt), ' in Sensor =', num2str(idxSensor)],'FontSize',16);
            print(gcf,'-painters','-dpng',fullfile(char(file_path),'Result','Sensor',num2str(idxSensor),pt));
        case 'Esti_Resamp'
            pt = [strcat(num2str(tt),'_c'),'.png'];
            title(['Estimated taregts and resampled or clipped particles at k = ',num2str(tt), ' in Sensor =', num2str(idxSensor)],'FontSize',16);
            print(gcf,'-painters','-dpng',fullfile(char(file_path),'Result','Sensor',num2str(idxSensor),pt));
    end
       
end

 

%     % draw undetect
%     for i = 1:nTarget
%         x_pos_i = x((i-1)*4+1,:);
%         y_pos_i = x((i-1)*4+2,:);
%         for j = 1:size(x_pos_i,2)
%             if(rand(1)>setup.PHD.P_detect)
%                 plot(x_pos_i(:,j),y_pos_i(:,j),'*k','LineWidth',2,'MarkerSize',12);  %# Plot eExampleh column with a
%             end
%         end
%     end
        
    
%     axis equal
    
    
%     export_fig('setup.pdf');
end

