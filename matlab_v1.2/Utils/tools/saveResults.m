function saveResults(ps, output)
%% specify file names and save results
%
% Input:
% ps: a structure containg the simulation setup and filter parameters.
% output: a structure containing the filtering outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = ['Results/', ps.setup.example_name, '_',...
    num2str(ps.setup.nParticle), 'particle_',...
    num2str(ps.setup.dimState_all), 'dimension_',...
    num2str(ps.setup.nTrack),...
    'tracks_',num2str(ps.setup.nAlg_per_track),'runs'];

if ~exist('Results', 'dir')
    mkdir('Results');
end

if ps.setup.regularize_resample
    filename = [filename, '_with_regularization'];
else
    filename = [filename, '_no_regularization'];
end

alg_string = [];

for ix = 1:length(ps.setup.algs_executed)
    alg_i = ps.setup.algs_executed{ix};
    alg_string = [alg_string, '_', alg_i];
end

%% initialize parameters for different dataset.
switch ps.setup.example_name
    case 'Acoustic'
        filename = [filename, alg_string, '.mat'];
    case 'Septier16'
        filename = [filename, '_',num2str(ps.setup.T),'timesteps_init_dist_', ...
        ps.initparams.init_dist, '_init_state_',...
        num2str(round(100*mean(ps.initparams.x0))),...
        '_',alg_string, '.mat'];
end

save(filename,'ps','output','-v7.3');
end