  function [vg,vgset,output] = initializationFilterPHD(args)
%% initialize filter outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs:
% args: setup
%
% Output:
% vg: a struct that contains the filter output
% vgset: 
% output: a struct that contains the filter estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps = args.Example; % notice that only setup.Example here
K = ps.K; % number of time steps duration
vgset = {};
output = struct('x_est',zeros(ps.dimState,K));%,'M',zeros(setup.setup.dimState,T), 'PU',zeros(setup.setup.dimState,setup.setup.dimState,T));
output.x_est_unweighted = output.x_est;

% Kalman variables
vg.M = zeros(ps.dimState,1); % EKF1/EKF2/UKF estimate
vg.PP = zeros(ps.dimState,ps.dimState); % EKF1/EKF2/UKF pred. covariance
vg.PU = zeros(ps.dimState,ps.dimState); % EKF1/EKF2/UKF upd. covariance

% setup.Initfcn: particle initialization function
[vg.xp,vg.M,vg.PU] = ps.initparams.initfcn(ps,args.nParticle); % Initialize particles, KF estimate and cov
vg.xp_m = vg.M;

vg.logW = zeros(1,size(vg.xp,2));

for i = 1:size(vg.xp,2)*4
    index = (1+(rem(i-1,4))*4):(4+(rem(i-1,4))*4);
    vgset(i).xp = vg.xp(index,fix((i-1)/4)+1); % particles state
    vgset(i).PP = vg.PP; % prediction covariance
    vgset(i).PU = vg.PU(1:4,1:4); % update covariance
    vgset(i).M  = vg.M(index,1); % estimate of a particle "mean value"
    vgset(i).xp_m = vgset(i).M; 
    vgset(i).logW = 0; % weight 
    vgset(i).w = 4/200; % weight 4 target / 200 particles 
    vgset(i).PD = 1; % ???  prob of detection
    vgset(i).B = 0; % ??? Birth??
end


end

