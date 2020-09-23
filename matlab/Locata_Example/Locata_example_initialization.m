function ps = Locata_example_initialization(ps)

ps.setup.nParticle = 50;% number of particles used in particle flow type algorithms.

% Simulation and Measurement Parameters
ps.setup.T = 100;
ps.setup.nTarget = 1;
ps.setup.dimState_per_target = 4;

% Error metrics
ps.setup.ospa_c = 40;
ps.setup.ospa_p = 1;

nTarget = ps.setup.nTarget;


% Dimension of sensorsPos: (2*nTarget) x nSensor
% x-coordinate replicated nTarget times
% y-coordinate replicated nTarget times 

% See paper for measurement model description
Amp = 10; %amplitude of the sound source (target)
invPow = 1; % rate of decay
d0 = 0.1; 
noise = 'Gaussian';  %measurement noise type
simAreaSize = 40;
x0 = [];
survRegion = [0,0,80,20];
trackBounds = [-10,-5,90,25];


% Motion model parameters
% For each target x_{k,i} = Phi*x_{k-1,i} + Gamma*sqrt(gammavar)*normrnd(2,1); 
Phi = [1 0 1 0;0 1 0 1;0 0 1 0;0 0 0 1];

Gamma = [1/3 0 0.5 0; 0 1/10 0 0.5; 0.5 0 1 0; 0 0.5 0 1];

% gammavar = 0.00035;
gammavar_real = 0.05;

Qii_real = gammavar_real*Gamma;

Qii = [3 0 0.1 0; 0 1 0 0.1; 0.1 0 0.01 0; 0 0.1 0 0.01];

A = Phi; % State update matrix
Q = Qii;
Q_real = Qii_real;
% multiGamma = Gii;

Q_ii_correction = 0.1*[1 0 0 0; 0 0.5 0 0;0 0 0.01 0;0 0 0 0.005];
%  Q_ii_correction = [1 0 0 0; 0 1 0 0;0 0 0.01 0;0 0 0 0.01];
Q_correction = Q_ii_correction;
% Replicate the matrices to reflect how many targets there are
for ii = 1:(nTarget-1)
    Phi = blkdiag(Phi,A);
    Q = blkdiag(Q,Qii);
    Q_real = blkdiag(Q_real,Qii_real);
    Q_correction = blkdiag(Q_correction,Q_ii_correction);
end

ps.initparams = struct(...
    'x0',x0,...
    'sigma0',[],...
    'nTarget',nTarget,...
    'survRegion',survRegion,...
    'simAreaSize',simAreaSize);

% ps.initparams.sigma0 = repmat(10*[0.1;0.1;0.0005;0.0005],nTarget,1);
ps.initparams.sigma0 = repmat([16;4;1;1],nTarget,1);

ps.propparams = struct(...
    'Phi',Phi,...
    'Q',Q,...
    'Q_correction', Q_correction,...
    'Q_regularized', Q_correction,...
    'nTarget',nTarget,...
    'propagatefcn',@AcousticPropagate,...
    'dimState_per_target',ps.setup.dimState_per_target);%'propagatefcn',@AcousticPropagate,...

ps.propparams_real = struct(...
    'Phi',Phi,...
    'Q',Q_real,...
    'nTarget',nTarget);
    
measvar_real = 1;
measvar = measvar_real;

ps.likeparams = struct('Amp',Amp,...
    'd0',d0,...
    'invPow',invPow,...
    'measvar', measvar,...
    'measvar_real',measvar_real,...
    'noise',noise,...
    'simAreaSize',simAreaSize,...
    'nTarget',nTarget,...
    'survRegion',survRegion,...
    'trackBounds',trackBounds);


ps.setup.plotfcn = @LocataParticlePlot;               % plotting function

ps.likeparams.llh = @Gaussian_llh;
ps.likeparams.h_func = @Locata_hfunc;
ps.likeparams.dh_dx_func = @Visual_dh_dxfunc;
ps.likeparams.dH_dx_func = @Visual_dH_dx;
ps.initparams.initfcn = @LocataGaussInit;             % filter initialization function
