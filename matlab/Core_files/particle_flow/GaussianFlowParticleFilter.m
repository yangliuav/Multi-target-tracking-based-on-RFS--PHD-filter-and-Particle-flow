function [output] = GaussianFlowParticleFilter(ps,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Particle filter with Gaussian flow according to the reference[R1]:
%
% Input:
% ps: a struct that contains model parameters.
% z: a measurement_dim x T matrix
%
% Output:
% output: a struct that contains the filter outputs, including the particle
% estimate, true state, execution time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Lingling Zhao, modified by Yunpeng Li
%
% [R1]"Bunch, Pete, and Simon Godsill. "Approximations of the optimal importance density using gaussian particle flow importance sampling." arXiv preprint arXiv:1406.3183 (2014)."

tic
nParticle = ps.setup.nParticle;

T = size(z,2);

gamma = 0;  % parameter gamma is to control the diffusion degree.

output = struct('x_est',zeros(ps.setup.dimState_all,T),'x',ps.x,'Neff',zeros(1,T));
[xp0,M,PU] = ps.initparams.initfcn(ps,ps.setup.nParticle); % Initialize particles, estimate and cov
epsilon0 = zeros(ps.setup.dimState_all,ps.setup.nParticle);
logW = log(ones(1,ps.setup.nParticle)/ps.setup.nParticle);

for tt = 1:T
    xp1 = ps.propparams.propagatefcn(xp0,ps.propparams);
    ps = updateMeasurementCov(xp0,ps);
    
    if ps.setup.doplot
       pause(0.1);
       vg.xp = xp1;
       vg.xp_m = particle_estimate(logW,xp1,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate
       ps.setup.plotfcn(vg,ps,zeros(size(xp1)),tt,'prior'); % call plot function  
    end

   [xp, logW] = GaussianFlow(z(:,tt), xp1, logW, ps, epsilon0, gamma, tt) ;
    
    wt = exp(logW);
%     if sum(wt)>1e-10
    wt = wt./sum(wt);
    if isnan(wt)
        wt = ones(1,nParticle)/nParticle;
        logW = log(wt);
    end
    
    % Form the estimate
    xp_m = particle_estimate(logW,xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate 
    
    output.x_est(:,tt) = xp_m;
    output.Neff(tt) = 1/sum(wt.^2);
        
    % Resample if necessary
    if ps.setup.Resampling && output.Neff(tt) < nParticle*ps.setup.Neff_thresh_ratio
        I = resample(nParticle,wt,'stratified');
        xp = xp(:,I);
        wt = 1/nParticle*ones(1,nParticle);
        logW = log(wt);       
        if ps.setup.doplot
            vg.xp = xp;
            vg.xp_m = xp_m;
            ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,['After resampling']); % call plot function  
        end
    end
    xp0 = xp;
end
output.execution_time = toc;
alg_name = 'GPFIS';
calculateErrors(output,ps,alg_name);
end