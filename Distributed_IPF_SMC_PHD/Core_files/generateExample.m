function example = generateExample(inp)
% This function implements proposed IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:

%% 

% Simulation and Measurement Parameters
example.T = inp.T;
example.K = inp.K;
nTarget = inp.nTarget;
example.nTarget = nTarget;
survRegion = inp.survRegion;
trackBounds = survRegion + [-10,-10,10,10];
noise = 'Gaussian'; % measurement noise type 
example.dimState = inp.dimState;

% Error metrics
example.ospa_c = inp.ospa_c;
example.ospa_p = inp.ospa_p;

x0 = inp.x0; % 4 target start point

% Motion model
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

Q_ii_correction = 0.1*[1 0 0 0; 0 1 0 0;0 0 0.01 0;0 0 0 0.01];
Q_correction = Q_ii_correction;
% Replicate the matrices to reflect how many targets there are
for ii = 1:(nTarget-1)
    Phi = blkdiag(Phi,A);
    Q = blkdiag(Q,Qii);
    Q_real = blkdiag(Q_real,Qii_real);
    Q_correction = blkdiag(Q_correction,Q_ii_correction);
end

example.initparams = struct(...
    'x0',x0,...
    'sigma0',[],...
    'nTarget',nTarget,...
    'survRegion',survRegion);

example.initparams.sigma0 = repmat(10*[1;1;0.1;0.1],nTarget,1);

% propparams and propparams_real difference? propparams_real is process
% model, propparamas estimation 
example.propparams = struct(...
    'Phi',Phi,...
    'Q',Q,...
    'Q_correction', Q_correction,...
    'Q_regularized', Q_correction,...
    'nTarget',nTarget,...
    'propagatefcn',@Propagate,...
    'dimState_per_target',inp.dimState);
example.initparams.initfcn = @GaussInit;             % filter initialization function


example.propparams_real = struct(...
    'Phi',Phi,...
    'Q',Q_real,...
    'nTarget',nTarget);
    
measvar_real = 1;
measvar = measvar_real; % measurement variance

example.likeparams = struct(...
    'measvar', measvar,...
    'measvar_real',measvar_real,...
    'noise',noise,...
    'nTarget',nTarget,...
    'survRegion',survRegion,...
    'trackBounds',trackBounds);
end

