function [vg,vgset,output] = initializationFilterPHD(setup)
%% initialize filter outputs
% inputs:
% setup: structure with filter and simulation parameters
%
% Output:
% vg: a struct that contains the filter output
% output: a struct that contains the filter estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps = setup.Ac;
T = ps.T; % number of time stesetup
vgset = {};
output = struct('x_est',zeros(ps.dimState_all,T));%,'M',zeros(setup.setup.dimState_all,T), 'PU',zeros(setup.setup.dimState_all,setup.setup.dimState_all,T));
output.x_est_unweighted = output.x_est;
% Kalman variables
vg.M = zeros(ps.dimState_all,1); % EKF1/EKF2/UKF estimate
vg.PP = zeros(ps.dimState_all,ps.dimState_all); % EKF1/EKF2/UKF pred. covariance
vg.PU = zeros(ps.dimState_all,ps.dimState_all); % EKF1/EKF2/UKF upd. covariance

% setup.Initfcn: particle initialization function
[vg.xp,vg.M,vg.PU] = ps.initparams.initfcn(ps,setup.nParticle); % Initialize particles, KF estimate and cov
vg.xp_m = vg.M;

vg.logW = zeros(1,size(vg.xp,2));

for i = 1:size(vg.xp,2)*4
    index = (1+(rem(i-1,4))*4):(4+(rem(i-1,4))*4);
    vgset(i).xp = vg.xp(index,fix((i-1)/4)+1);
    vgset(i).PP = vg.PP;
    vgset(i).PU = vg.PU(1:4,1:4);
    vgset(i).M  = vg.M(index,1);
    vgset(i).xp_m = vgset(i).M;
    vgset(i).logW = 0;
    vgset(i).w = 4/200;
    vgset(i).PD = 1;
    vgset(i).B = 0;
end


end

