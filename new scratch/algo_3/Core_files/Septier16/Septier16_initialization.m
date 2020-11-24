function ps = Septier16_initialization(ps)
%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the simulation setup and filter parameter values for the
% "Septier16" example
% Input:
% ps: a structure containg the simulation setup and filter parameters.
% Output:
% ps: a structure containg the simulation setup and filter parameters.
%%%%%%%%%%%%%%%%%%%%%%%%

ps.setup.nTrack = 100;% the number of different states/measurements.
ps.setup.nAlg_per_track = 1;% the number of different execution for each algorithms on the same measurements.
ps.setup.nParticle = 200;% number of particles used in particle flow type algorithms.

%% Simulation area
ps.setup.T=10;
init_dist = 'delta';%delta means we know the true initial state and set it that way.
dim = 20^2;
ps.setup.dimState = dim;
ps.setup.domain=[1 sqrt(ps.setup.dimState)];%[0 30];

ps.setup.nSensor=ps.setup.dimState; % Dimension of the observation 
% Sensors placed on a regular grid
[XSensors,YSensors]=meshgrid(linspace(ps.setup.domain(1),ps.setup.domain(2),sqrt(ps.setup.nSensor)));
ps.setup.sensorPosition=reshape(XSensors,1,[]);
ps.setup.sensorPosition=[ps.setup.sensorPosition;reshape(YSensors,1,[])];

%% Prior
% x0 = log(10)*ones(ps.setup.dimState,1);
x0 = zeros(ps.setup.dimState,1);
stateCovParam = [];
stateCovParam(1) = 3; % Variance
stateCovParam(2) = 20; % Length scale of the exp in Correlation
stateCovParam(3) = 0.01;

stateCovariance=KernelStateDynamics(ps.setup.sensorPosition,stateCovParam);
stateCovariance=stateCovariance+stateCovParam(3)*eye(ps.setup.dimState);

stateCovariance=triu(stateCovariance,1)+triu(stateCovariance,1)'+diag(diag(stateCovariance));
stateCovarianceSR=real(sqrtm(stateCovariance));
stateCovarianceInv=real(inv(stateCovariance));
% stateCovarianceDet=real(det(stateCovariance));

stateSkewness=0.3*ones(ps.setup.dimState,1); % Skewness when GH Skewed-t Used
stateDegreeFreedom=7;% \nu Degree Freedom when GH Skewed-t Used

lambda = -stateDegreeFreedom/2;
ksi = stateDegreeFreedom;
% Computation of Covariance SkewedtT
a=stateDegreeFreedom/2;
b=a;
MeanW=b/(a-1);
VarW=(b^2)/(((a-1)^2)*(a-2));
stateCovSkewedT=MeanW*stateCovariance+VarW*stateSkewness*stateSkewness';

switch init_dist
    case 'delta'
        initCov = eps*eye(size(stateCovariance));
end

alpha = 0.9;

ps.initparams = struct(...
    'x0',x0/alpha,...
    'init_dist',init_dist,...
    'initCov',initCov,...
    'initfcn',@Septier16_init);

%% Dynamic model
transitionMatrix=alpha*eye(ps.setup.dimState);

ps.propparams = struct(...
    'transitionMatrix',transitionMatrix,...
    'stateDegreeFreedom',stateDegreeFreedom,...
    'stateSkewness',stateSkewness,...
    'stateCovarianceSR',stateCovarianceSR,...
    'stateCovarianceInv',stateCovarianceInv,...
    'lambda',lambda,...
    'ksi',ksi,...
    'Q',stateCovSkewedT,...
    'Q_regularized',0.01*stateCovSkewedT,...
    'propagatefcn',@Septier16_propagate);

%% Measurement model
mappingIntensityCoeff=1;
mappingIntensityScale=3;

observationTransition=eye(ps.setup.dimState); % Required to Map supp(X_k) to supp(Y_k)

ps.likeparams = struct('observationTransition', observationTransition,...
    'mappingIntensityCoeff',mappingIntensityCoeff,...
    'mappingIntensityScale',mappingIntensityScale,...
    'h_func',@Septier16_hfunc,...
    'dh_dx_func',@Septier16_dh_dxfunc,...
    'dH_dx_func',@Septier16_dH_dx,...
    'observation_noise','poisson');%'poisson','normal'

switch ps.likeparams.observation_noise
    case 'normal'
        ps.likeparams.llh = @Gaussian_llh;
    case 'poisson'
        ps.likeparams.llh = @Poisson_llh;
end

%%
ps.setup.plotfcn = @Septier16_ParticlePlot;               % plotting function
