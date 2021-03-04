% This file demonstrates how to initialize the algorithms






% References:
% Y Liu, W. Wang
% "Audio-visual Zero Diffusion Particle FlowSMC-PHD Filter for Multi-speaker Tracking,"

%
% The codes & data have been deposited to https://github.com/jd0710/MNR-ADL-SR
%
% Written by Yang Liu, moderated by Wenwu Wang, version 1.0                                    
%
% If you have any questions or comments regarding this package, or if you want to 
% report any bugs or unexpected error messages, please send an e-mail to
% yangliu@surrey.ac.uk
%         
% Copyright 2017 Y Liu, W. Wang
% 
% This software is a free software distributed under the terms of the GNU 
% Public License version 3 (http://www.gnu.org/licenses/gpl.txt). You can 
% redistribute it and/or modify it under the terms of this licence, for 
% personal and non-commercial use and research purpose. 

%%  Path
if exist('result/Groundtrue','dir')==0
    mkdir result Groundtrue
end

setup.alg_path = fileparts(mfilename('fullpath'));
%%  Setup
% setup: the setup information about the algorithms
% {
%   algs: the algorithms are used.
%   cam : the camera index of AV 16.3
%   sequence : the sequence name of AV 16.3
%   seed : the ramdon seed   
%   resultsPath : the path of saving result.
%   colormodel : the color model 
%   bins       : the bin number of the histogram 
%   ospa_c : the parameter c of the OSPA
%   osps_p : the parameter p of the OSPA
%   initvel: the initial value of the vel 
%   sigma  : noise of variance
%   sigma_scale : variance of the noise of the scale parameter
%   Wk_resample : the resampled particle weight
%   Kflag : the name of the EKF method
%   resample :  whether resample particles
%   redraw : whether redraw particles
%   use_cluster : whether use cluster
%   maxilikeSAP : parameters for calculating the particle estimate
%   maxilikemode : the mode for calculating the particle estimate
%   nTrial :   
%   weight_euclidean : the weight of Euclidean distances when performing clustering using 'euclidean_slope'
%   nParticleCluster : number of particle clusters used to calculate the slope
%   Neff_thresh_ratio : the thresh of ESS
%   nParticle : number of particles
%}
setup.algs = {'IPF-SMC_PHD'}; %, 'ZPF-SMC_PHD','NPF-SMC_PHD' ,'SMC_PHD','NPF-SMC_PHD_S','IPF-SMC_PHD' 

setup.ospa_c = 40;
setup.ospa_p = 1;
setup.initvel = 4;

setup.sigma         =   50;     
setup.sigma_scale   =   0.1;    


setup.Wk_resample     =   0;
setup.kflag           =   'EKF1';%'EKF1','regularized_identity',...'none'; % the method used to estimate the prior covariance.
setup.resample        =   true;
setup.redraw		  =   true;
setup.use_cluster  = false;
setup.maxilikeSAP	  =   200;
setup.maxilikemode    =   'a';
setup.nTrial		  =   1; %
setup.bins            =   16;
setup.weight_euclidean = 0.25; % the weight of Euclidean distances when performing clustering using 'euclidean_slope'.
setup.nParticleCluster = 100;% Number of particle clusters used to calculate the slope in the LEDH-variant algorithms.
setup.Neff_thresh_ratio = 0.5;
setup.nParticle = 50;
setup.clutter = 2;
setup.detect  = 0.99; 
setup.lambda_range = linspace(0,1,29);


%%  Inp
%inp: data information
%{
%   K : number of video frames
%   T : duration of each frame
%   Z_doa : DOA lines
%   Z_SRP : SRP-PHAT data
%   his_temp : histogram of the reference model 
%   angle_prev : the audio angle at last frame
%   start : the frame of start tracking
%}
inp.ztype = 'SRP'; %'DOA' or 'SRP'
inp.K = video.NumFrames;
inp.T = 1;%video.FrameRate;
inp.H = [1,0,0,0;0,1,0,0]';
inp.nspeaker = 3;
inp.example_name = 'Real_Data';
inp.random_seeds = randsample(1e5*inp.nspeaker,inp.nspeaker);
inp.dimState_all = 4;

Ac = AV_example_initialization(inp);
setup.Ac = Ac;

%%  Output
%out:
%{
%   print_frame : whether print frame
%   plot_particles : whether plot particles on the frames
%   draw_audio : whether draw audio information ( DOA lines or SRP points)
%   save_frame : whether save frames 
%   save_data  : whether save experiment data
%}
out.print_frame = 1;
out.plot_particles = 0;
out.draw_audio = 0;
out.save_frame = 1;
out.save_data = 1;


%%  PFlow
%PFlow:
%{
%   lambda_type : the type of choosing lambda ('exponential'; 'uniform';)
%   nlambda : the number of lambda
%}
PFlow.lambda_type = 'exponential'; % 'uniform';
PFlow.nlambda = 100;


%%  PHD
%PHD:
%{
%   x_dim : dimensionality of particle state
%   P_death : probability of speaker death 
%   P_detect : probability of detection in measurements or (1 - P_miss) 
%   F : Linear motion model
%   lambda_b : Average rate of speaker birth (per scan)
%   tilde_Xk : the initial particle state
%   bar_x : the born particle state
%   bar_B : the variance of born particle
%   lambda_c : average rate of clutter (per scan). 
%   range_c :  clutter intervals 
%   lambda_s : Average rate of speaker spawn (per scan)
%   lmax :  max. allowable particles
%   rho : no. of particles per survived speaker 
%   Jk : no. of particles for birth speakers
%   Lk : no. of sum wights
%   hat_N : hard estimate of the number of speakers
%   hat_N_soft : soft estimate of the number of speakers
%   hat_X : Cell for estimated positions of the speakers
%   chk_x : the state of peaker spawn
%   chk_F : fuction of peaker spawn
%   sigma_s :Sigma_scale of peaker spawn 
%   Q:  the covariance of particle for updating
%   L_b : the likelihood for born speaker
%   posn_interval :interval of speakers
%   H : the observation model
%   simTarget1State : the target state at frame 1 
%}
PHD.x_dim = 5;
PHD.P_death   =   0.01;   % The probability of speaker death  
PHD.P_survival = 0.99;
PHD.P_detect     =   0.8;   % The probability of detection in measurements or (1 - P_miss) 
PHD.F  =   [1,inp.T,0,0,0;           % Linear motion model
                    0,1,0,0,0; 
                    0,0,1,inp.T,0; 
                    0,0,0,1,0;  
                    0,0,0,0,1];

PHD.lambda_b = 0.1; 
PHD.tilde_Xk = [ 5; setup.initvel; 75; setup.initvel;1 ];
PHD.bar_x = [ 5; setup.initvel; 75; setup.initvel;1 ]; 
PHD.bar_B = diag([ 20; 5; 50; 5; 1 ]);
PHD.lambda_c  =   0.26;   % Average rate of clutter (per scan). 
%PHD.range_c   =  [0 inp.TrackedMov.Width; 0 inp.TrackedMov.Height]; % clutter intervals 360 x 288
PHD.lambda_s  = 0.1;
PHD.lmax      = 1e5;      %   max. allowable particles
PHD.rho	      = 50;
PHD.Jk		  = 50;
PHD.Lk		  = 1;
PHD.hat_N           =   zeros(inp.K,1);     % hard estimate of the number of speakers
PHD.hat_N_soft      =   zeros(inp.K,1);     % soft estimate of the number of speakers
PHD.hat_X           =   cell(inp.K,1);      % Cell for estimated positions of the speakers
PHD.chk_x           =   zeros(PHD.x_dim,1); 
PHD.chk_F(:,:,1)  =   eye(PHD.x_dim); 
PHD.sigma_s(1)    =   1;
Q          =   [1, 0; 0, 0.1];
Q          =   Q*setup.sigma;
PF.Q     = Q;
PHD.Q    =   [Q, zeros(2,2) ,zeros(2,1); 
                zeros(2,2), Q ,zeros(2,1);
                zeros(1,2), zeros(1,2), setup.sigma_scale]; 
clear Q;  % We do not need "Q" anymore  
PHD.L_b      = 1;
% PHD.posn_interval = [   0 inp.TrackedMov.Width ;
%                             0 setup.initvel;
%                             0  inp.TrackedMov.Height;
%                             0 setup.initvel;
%                             0 1]; 
PHD.H	   =   [1, 0, 0, 0, 0;
				0, 0, 1, 0, 0];
% PHD.simTarget1State = [inp.x0_1,inp.x0_2;
%                        0,0;
%                        inp.y0_1,inp.y0_2;
%                        0,0;
%                        1,1;];
PHD.calculateDataRange4 = @(j) (4*(j-1)+1):(4*j);

%%  PF
%PF:
%{
%   F : the equation of state
%   x_dim : the dimension of particle state
%   dimState_all : PF.x_dim*inp.nspeaker;
%   M : EKF1/EKF2/UKF estimate
%   PP : EKF1/EKF2/UKF pred. covariance
%   PU : EKF1/EKF2/UKF upd. covariance
%   xp : particle state
%   w :  particle weight
%   likeparams.R : the error of the likelihood
%}
PF.F 			= [1,1;0,1];
PF.x_dim		= 4;
PF.dimState_all	= PF.x_dim*inp.nspeaker;
PF.M = zeros(PF.dimState_all,1); % EKF1/EKF2/UKF estimate
PF.PP = zeros(PF.dimState_all/2,PF.dimState_all/2); % EKF1/EKF2/UKF pred. covariance
for i= 1: inp.nspeaker	
    PF.PP((i*2-1):i*2,(i*2-1):i*2) = PF.Q;
end
PF.QP = PF.PP;
PF.PU = zeros(PF.dimState_all,PF.dimState_all); % EKF1/EKF2/UKF upd. covariance
PF.xp = [];
for i = 1:inp.nspeaker
    PF.F =blkdiag(PF.F,PF.F);
end
PF.xp = [normrnd(40,1,[1 PHD.rho]) ; normrnd(1,0.5,[1 PHD.rho]) ;normrnd(45,1,[1 PHD.rho]) ; normrnd(1,0.5,[1 PHD.rho]) ;normrnd(52,1,[1 PHD.rho]) ; normrnd(1,0.5,[1 PHD.rho]) ;normrnd(57,1,[1 PHD.rho]) ; normrnd(1,0.5,[1 PHD.rho]) ];
PF.w = ones(1,size(PF.xp,2))/size(PF.xp,2);
PF.likeparams.R = eye(4)*5;
%GM_EKF_PHD_Initialise_Jacobians;

%%  
setup.inp = inp;
setup.out = out;
setup.PHD = PHD;
setup.PF  = PF; 

clear inp;
clear out;
clear PHD;
clear PF;
%setup.inp