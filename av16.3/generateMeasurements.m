function setup = generateMeasurements(setup, video, Data, face)
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
    x = Data.posGT.X_true;% groundtruth    load Data
    %c = [];% clutter no use
    y = face;
%     if ~isempty(face(1))
%         y = zeros(1,12);% measurement face[] dic{face(),audio (Q)} deep learning(face,mat)
%     else
%         y = face(1);
%     end
    
    x_all{track_ix}=x;
    y_all=y;
        
    x_all_mat(:,:,track_ix) = x;
    y_all_mat = y;
end
setup.inp.x_all = x_all;
setup.inp.y_all = y_all;
%setup.inp.c_all = c_all;
disp('Starting filtering algorithms:');


% plot real graph
if setup.out.print_frame 
    nTarget = size(x,1)/4;
%     nClutter = size(c,1)/4;
    cmap = hsv(nTarget+3);  %# Creates a 6-by-3 set of colors from the HSV colormap

    fontsize = 24;
%     simAreaSize=40; %size of the area
    figure(1);
    imshow(read(video,1));
    hold on;
    % draw targets
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);
        x_pos_i(x_pos_i==0) = NaN;
        y_pos_i(y_pos_i==0) = NaN;
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
    
    h_leg=legend('Target 1','Target 2','Target 3');
    set(h_leg,'FontSize',fontsize,'Location','southeast');


    set(gcf,'color','w');

    title('GroundTruth');
    dt = datestr(now,'yyyymmddHHMM')
    dt = [dt,'.png'];
    
    file_path = fileparts(mfilename('fullpath'));
    
    print(gcf,'-painters','-dpng',fullfile(file_path,'result','Groundtrue',dt));

end

end

