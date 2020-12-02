function ps = initializePS(algs_executed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize parameters for simulation setup and filtering algorithms.
%
% Input:
% algs_executed: a cell containing the names of filtering algorithms to be executed.
%
% Output:
% ps: a structure containg the simulation setup and filter parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% first initialize parameters common for all datasets.
ps.setup = struct(...
'example_name','Acoustic',...'Septier16','Acoustic'.
'doplot', true,...% plot the tracking trajectories
'parallel_run', false,... % using parallel processing for different simulation trials
'algs_executed',{algs_executed},...
'lambda_type','exponential',...% 'uniform';
'nLambda',29,...% number of intermediate steps within one particle flow
'PFPF',true,...
'kflag','EKF1',...%'EKF1','regularized_identity',...'none'; % the method used to estimate the prior covariance.
'regularize_resample',false,...% whether to add regularization noise
'fontSize',20,...
'Resampling',true,...% resample in the filter?
'Redraw',true,... % use redraw in EDH/LEDH
'maxilikeSAP',200,...  % parameters for calculating the particle estimate
'maxilikemode','a',... % 
'use_cluster',false);

%% for particle flow algorithms with clustering
ps.setup.weight_euclidean = 0.25; % the weight of Euclidean distances when performing clustering using 'euclidean_slope'.
ps.setup.nParticleCluster = 100;% Number of particle clusters used to calculate the slope in the LEDH-variant algorithms.
ps.setup.doplot_cluster = false;

ps.setup.Neff_thresh_ratio = 0.5;

addpath('ekfukf');
addpath('particle_filter');
addpath('particle_flow');
addpath('SmHMC');
addpath('plotting');
addpath('tools');

% set the intermediate time steps within the particle flow.
switch ps.setup.lambda_type
    case 'uniform'
        ps.setup.lambda_range = linspace(0,1,ps.setup.nLambda);
    case 'exponential'
        ps.setup.lambda_range = generateExponentialLambda(ps.setup.nLambda);
end

%% initialize parameters for different dataset.
switch ps.setup.example_name
    case 'Acoustic'
        addpath('Acoustic_Example');
        ps = Acoustic_example_initialization(ps);
    case 'Septier16'
        addpath('Septier16');
        ps = Septier16_initialization(ps);
end

ps.setup.nTrial = ps.setup.nTrack*ps.setup.nAlg_per_track;

% random seeds are initilized here so that each trial is repeatable even
% if we use parfor loops.
ps.setup.random_seeds = randsample(1e5*ps.setup.nTrial,ps.setup.nTrial);

% There is a bad track in Trial 69 when the total number of tracks is set to 100
% for the Septier16 example, as there is a large gap between states in one time step.
% So, we add the random seed by 1 in that simulation trial to avoid the bad track.
% if strcmp(ps.setup.example_name,'Septier16') && ps.setup.nTrack == 100 && ps.setup.dimState==144
%     ps.setup.random_seeds(69) = ps.setup.random_seeds(69)+1;
% end

% the overall state dimension
if isfield(ps.setup,'nTarget')
    ps.setup.dimState_all = ps.setup.nTarget * ps.setup.dimState_per_target;
else
    ps.setup.dimState_all = ps.setup.dimState;
end

ps.SmHMC_model_params = generateSmHMCModelParam(ps);
