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
    
    x_all{track_ix}=x;
    y_all=y;
        
    x_all_mat(:,:,track_ix) = x;
    y_all_mat = y;
end
setup.inp.x_all = x_all;
setup.inp.y_all = y_all;
%setup.inp.c_all = c_all;
disp('Starting filtering algorithms:');


% No need to plot out Ground Truth

end

