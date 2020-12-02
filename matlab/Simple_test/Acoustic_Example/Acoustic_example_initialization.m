function ps = Acoustic_example_initialization(ps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializes the parameter structure for the acoustic sensor example
%
% Input:
% ps: a structure containg the simulation setup and filter parameters.
%
% Output:
% ps: a structure containg the simulation setup and filter parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps.setup.nTrack = 1;% the number of different states/measurements. It is set to 100 in [li2016].
ps.setup.nAlg_per_track = 5;% the number of different execution for each algorithms on the same measurements.
ps.setup.nParticle = 500;% number of particles used in particle flow type algorithms.

% Simulation and Measurement Parameters
ps.setup.T=40;
ps.setup.nTarget =4;
ps.setup.dimState_per_target = 4;

% Error metrics
ps.setup.ospa_c = 40;
ps.setup.ospa_p = 1;

nTarget = ps.setup.nTarget;
load 'sensorsXY';
simAreaSize=40; %size of the area

sensorsPos = simAreaSize/40*sensorsXY; %physical positions of the sensors
nSensor = size(sensorsPos,1);

% Copy the sensor positions so that they are easier for per-target
% processing
sensorsPos = sensorsPos';
ps.sensorsPosO = sensorsPos;
sensorsPos = kron(sensorsPos,ones(nTarget,1));

% Dimension of sensorsPos: (2*nTarget) x nSensor
% x-coordinate replicated nTarget times
% y-coordinate replicated nTarget times 

% See paper for measurement model description
Amp = 10; %amplitude of the sound source (target)
invPow = 1; % rate of decay
d0 = 0.1; 
noise = 'Gaussian';  %measurement noise type

switch nTarget
    case 4
        % Initialization: 4 targets
        x0 = [12 6 0.001 0.001 32 32 -0.001 -0.005 20 13 -0.1 0.01 15 35 0.002 0.002]';
        survRegion = [0,0,40,40];
        trackBounds = [-10,-10,50,50];
end

if length(x0)~= 4* nTarget
    error('incorrect initial state dimension');
end

% Motion model parameters
% For each target x_{k,i} = Phi*x_{k-1,i} + Gamma*sqrt(gammavar)*normrnd(2,1); 
Phi = [1 0 1 0;0 1 0 1;0 0 1 0;0 0 0 1];

Gamma = [1/3 0 0.5 0; 0 1/3 0 0.5; 0.5 0 1 0; 0 0.5 0 1];

% gammavar = 0.00035;
gammavar_real = 0.05;

Qii_real = gammavar_real*Gamma;

Qii = [3 0 0.1 0; 0 3 0 0.1; 0.1 0 0.03 0; 0 0.1 0 0.03];

A = Phi; % State update matrix
Q = Qii;
Q_real = Qii_real;
% multiGamma = Gii;

Q_ii_correction = 0.1*[1 0 0 0; 0 1 0 0;0 0 0.01 0;0 0 0 0.01];
%  Q_ii_correction = [1 0 0 0; 0 1 0 0;0 0 0.01 0;0 0 0 0.01];
Q_correction = Q_ii_correction;
% Replicate the matrices to reflect how many targets there are
for ii = 1:(nTarget-1)
    Phi = blkdiag(Phi,A);
    Q = blkdiag(Q,Qii);
    Q_real = blkdiag(Q_real,Qii_real);
    Q_correction = blkdiag(Q_correction,Q_ii_correction);
end;

ps.initparams = struct(...
    'x0',x0,...
    'sigma0',[],...
    'nTarget',nTarget,...
    'survRegion',survRegion,...
    'simAreaSize',simAreaSize);

% ps.initparams.sigma0 = repmat(10*[0.1;0.1;0.0005;0.0005],nTarget,1);
ps.initparams.sigma0 = repmat(10*[1;1;0.1;0.1],nTarget,1);

ps.propparams = struct(...
    'Phi',Phi,...
    'Q',Q,...
    'Q_correction', Q_correction,...
    'Q_regularized', Q_correction,...
    'nTarget',nTarget,...
    'propagatefcn',@AcousticPropagate,...
    'dimState_per_target',ps.setup.dimState_per_target);

ps.propparams_real = struct(...
    'Phi',Phi,...
    'Q',Q_real,...
    'nTarget',nTarget);
    
measvar_real = .01;
measvar = measvar_real;

ps.likeparams = struct('sensorsPos',sensorsPos,... 
    'Amp',Amp,...
    'd0',d0,...
    'invPow',invPow,...
    'measvar', measvar,...
    'measvar_real',measvar_real,...
    'noise',noise,...
    'simAreaSize',simAreaSize,...
    'nTarget',nTarget,...
    'nSensor',nSensor,...
    'dimMeasurement_per_target',nSensor,...
    'dimMeasurement_all',nSensor,...);
    'survRegion',survRegion,...
    'trackBounds',trackBounds);

ps.likeparams.R_real = measvar_real*eye(nSensor);
ps.likeparams.R = measvar*eye(nSensor);
ps.likeparams.R_inv = inv(ps.likeparams.R);

ps.setup.plotfcn = @AcousticParticlePlot;               % plotting function

ps.likeparams.llh = @Gaussian_llh;
ps.likeparams.h_func = @Acoustic_hfunc;
ps.likeparams.dh_dx_func = @Acoustic_dh_dxfunc;
ps.likeparams.dH_dx_func = @Acoustic_dH_dx;
ps.initparams.initfcn = @AcousticGaussInit;             % filter initialization function
