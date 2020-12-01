function [output] = BootstrapParticleFilter(ps,z)
% The implementation of BPF filters.
%
% Input:
% ps: a struct that contains model parameters.
% z: a measurement_dim x T matrix
%
% Output:
% output: a struct that contains the BPF outputs, including the particle
% estimate, true state, execution time, and the ESS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
T = size(z,2);

nParticle = ps.setup.nParticle;

[vg,output] = initializationFilter(ps);

xp = vg.xp;
logW = vg.logW;

for tt = 1:T
    ps.propparams.time_step = tt;
    xp = ps.propparams.propagatefcn(xp,ps.propparams);
    
    llh = ps.likeparams.llh(xp,z(:,tt),ps.likeparams);
   
    logW = logW + llh;
    logW = logW - max(logW);
    wt = exp(logW);
    wt = wt./sum(wt);
    if isnan(wt)
        wt = ones(1,nParticle)/nParticle;
        logW = log(wt);
        output.Neff(tt) = 1;
    else
        output.Neff(tt) = 1/sum(wt.^2);
    end
       
    % Form the estimate
    xp_m = particle_estimate(logW,xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode);
    
    output.x_est(:,tt) = xp_m;
        
    if ps.setup.doplot
        pause(0.1)
        vg.xp = xp;
        vg.xp_m = xp_m;
        ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'');
    end 
    
    if ps.setup.Resampling && output.Neff(tt) < nParticle*ps.setup.Neff_thresh_ratio
        I = resample(nParticle,wt,'stratified');
        xp = xp(:,I);
        wt = 1/nParticle*ones(1,nParticle);
        logW = log(wt);
        
        if ps.setup.regularize_resample
            added_term = mvnrnd(zeros(size(vg.xp')),ps.propparams.Q_regularized);

            vg.xp = vg.xp + added_term';

            if ps.setup.doplot
                ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'regularized resample');
            end
        end
    end
end

output.x = ps.x;
output.execution_time = toc;
alg_name = ['BPF (', num2str(nParticle),'Particles)'];
calculateErrors(output,ps,alg_name);
end