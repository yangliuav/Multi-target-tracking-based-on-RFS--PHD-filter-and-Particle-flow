function ps = generateMeasurements(ps)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate Grundtruth, clusster, measurement

disp('Generating tracks and measurements:');

nTrack = ps.inp.nTarget;
x_all = {};
y_all = {};

rng(ps.inp.random_seeds(1),'twister');
if ps.experiment == 'simulation'
    x = VisualGenerateTracksPHD(ps); % GT
    c = VisualGenerateClutterPHD(ps); % clutter
    % generate 5 different measurements from different sensor
    for i = 1:ps.model.nAgent % need fix auto
        Y{i} = VisualGenerateMeasurementsPHD(x,c,ps);% measurement
    end
    c_all{1}=c;
    c_all_mat(:,:,1) = c;
elseif ps.experiment == 'real_data'
%         x = ; % load GT
%         y = ; % load measurement
end
x_all{1}=x;
y_all=Y;

ps.inp.x_all = x_all;
ps.inp.y_all = y_all;
ps.inp.c_all = c_all;
%%
disp('Starting filtering algorithms:');

ps.inp.plot_flag = 'initial'; % plotting flat for initial or each frame
% only plot one GT 
if 1%ps.out.print_frame 
   plotting(ps,1);
end
ps.inp.plot_flag = 2;
end

