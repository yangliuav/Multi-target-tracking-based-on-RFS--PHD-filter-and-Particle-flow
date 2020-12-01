function ps = generateTracksMeasurements(ps)
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

nTrack = ps.setup.nTrack;
x_all = {};
y_all = {};

x_all_mat = [];
y_all_mat = [];

example_name = ps.setup.example_name;

if ps.setup.parallel_run
    x=[];
    y=[];
    doplot_original = ps.setup.doplot;
    ps.setup.doplot = false;
    gcp();
    parfor track_ix = 1:nTrack
        x = [];
        y = [];
        rng(ps.setup.random_seeds(track_ix),'twister');
        % Generate the signal
        % The transition matrix is random and is set inside this function 
        switch example_name
            case 'Acoustic'
                x = GenerateTracks(ps);    
        %         ps.x = GenerateTracks_bounce(ps);    
                y = GenerateMeasurements(x,ps);
            case 'Septier16'
                % there are bad tracks originally at trial_ix = 69, so
                % random seeds are changed
                [x,y] = generateSeptier16TrackMeasurements(ps);
        end
        x_all{track_ix}=x;
        y_all{track_ix}=y;
    end
    
    ps.setup.doplot = doplot_original;
else
    if nTrack > 5 && strcmp(example_name,'Acoustic')
        warning(['The track generation can be slow if you generate a large number of tracks',...
            ' for the Acoustic example. Consider setting the number of tracks to a smaller number',...
            ' for debugging or other testing only purposes, or setting ps.setup.parallel_run to true.']);
    end
    for track_ix = 1:nTrack
        rng(ps.setup.random_seeds(track_ix),'twister');
        % Generate the signal
        % The transition matrix is random and is set inside this function 
        switch example_name
            case 'Acoustic'
                x = GenerateTracks(ps);    
                y = GenerateMeasurements(x,ps);
            case 'Septier16'
                [x,y] = generateSeptier16TrackMeasurements(ps);
        end
        x_all{track_ix}=x;
        y_all{track_ix}=y;
        
        x_all_mat(:,:,track_ix) = x;
        y_all_mat(:,:,track_ix) = y;
    end
end
ps.x_all = x_all;
ps.y_all = y_all;

disp('Starting filtering algorithms:');

end

