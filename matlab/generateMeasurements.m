function setup = generateMeasurements(setup)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates state values and measurements for different
% trials.
%
% Input:
% ps: a structure containg the simulation setup and filter parameters.
%
% Output:
% ps: a structure containg the simulation setup and filter parameters,
%     and all true tracks and observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Generating tracks and measurements:');

nTrack = setup.inp.nspeaker;
x_all = {};
y_all = {};

x_all_mat = [];
y_all_mat = [];

example_name = setup.inp.example_name;

if nTrack > 5 && strcmp(example_name,'Acoustic')
    warning(['The track generation can be slow if you generate a large number of tracks',...
            ' for the Acoustic example. Consider setting the number of tracks to a smaller number',...
            ' for debugging or other testing only purposes, or setting ps.setup.parallel_run to true.']);
end

for track_ix = 1:1
    rng(setup.inp.random_seeds(track_ix),'twister');
    switch example_name
        case 'Acoustic'
            x = GenerateTracksPHD(setup);    
            c = GenerateClutterPHD(setup); 
            y = GenerateMeasurementsPHD(x,c,setup);
        case 'Septier16'       
        [x,y] = generateSeptier16TrackMeasurements(setup);
        case 'Visual'
            x = VisualGenerateTracksPHD(setup);    
            c = VisualGenerateClutterPHD(setup); 
            y = VisualGenerateMeasurementsPHD(x,c,setup);
        case 'Real_Data'
            x = VisualGenerateTracksPHD(setup);    
            c = VisualGenerateClutterPHD(setup); 
            y = VisualGenerateMeasurementsPHD(x,c,setup);
    end
    x_all{track_ix}=x;
    c_all{track_ix}=c;
    y_all=y;
        
    x_all_mat(:,:,track_ix) = x;
    c_all_mat(:,:,track_ix) = c;
    y_all_mat = y;
end
setup.inp.x_all = x_all;
setup.inp.y_all = y_all;
setup.inp.c_all = c_all;
disp('Starting filtering algorithms:');

if setup.out.print_frame 
    nTarget = size(x,1)/4;
    nClutter = size(c,1)/4;
    cmap = hsv(nTarget+3);  %# Creates a 6-by-3 set of colors from the HSV colormap
    figure(20);clf;hold on;
    set(gcf, 'Position', [100, 100, 1000, 900]);
    fontsize = 24;
    simAreaSize=40; %size of the area

    % draw targets
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);
        plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',2,'MarkerSize',7);  %# Plot each column with a
    end
    % draw start point
    x_pos_i = [];
    y_pos_i = [];
    for i = 1:nTarget
        x_pos_i(i) = x((i-1)*4+1,1);
        y_pos_i(i) = x((i-1)*4+2,1);      
    end
    plot(x_pos_i,y_pos_i,'xk','LineWidth',3,'MarkerSize',30);  %# Plot each column with a
    % draw clutters
    x_pos_i = [];
    y_pos_i = [];
    for i = 1:nClutter
        for t = 1:size(c,2)
            x_pos_i(t+(size(c,2)-1)*i) = c((i-1)*4+1,t);
            y_pos_i(t+(size(c,2)-1)*i) = c((i-1)*4+2,t);
        end
    end
    plot(x_pos_i,y_pos_i,'ob','LineWidth',1,'MarkerSize',4);  %# Plot each column with a
    
%     % draw undetect
%     for i = 1:nTarget
%         x_pos_i = x((i-1)*4+1,:);
%         y_pos_i = x((i-1)*4+2,:);
%         for j = 1:size(x_pos_i,2)
%             if(rand(1)>setup.PHD.P_detect)
%                 plot(x_pos_i(:,j),y_pos_i(:,j),'*k','LineWidth',2,'MarkerSize',12);  %# Plot each column with a
%             end
%         end
%     end
        
    h_leg=legend('Target 1','Target 2','Target 3','Target 4','Starting position','Clutter','Undetected state');
    set(h_leg,'FontSize',fontsize,'Location','southeast');

    grid on;
%     axis equal
    axis(setup.Ac.likeparams.survRegion([1,3,2,4]))
    set(gca,'xtick',0:10:40,'ytick',0:10:40,'FontSize',fontsize);
    set(gcf,'color','w');
    xlabel('X (m)','FontSize',fontsize);
    ylabel('Y (m)','FontSize',fontsize);
    dt = datestr(now,'yyyymmddHHMM')
    dt = [dt,'.png'];
    
    file_path = fileparts(mfilename('fullpath'));
    
    print(gcf,'-painters','-dpng',fullfile(file_path,'result','Groundtrue',dt));
%     export_fig('setup.pdf');
end

end

