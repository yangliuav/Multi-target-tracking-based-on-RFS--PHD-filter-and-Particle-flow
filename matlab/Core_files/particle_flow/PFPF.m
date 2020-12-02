function [output] = PFPF(ps,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement the Particle flow particle filter.
%
% Inputs:
% ps: structure with filter and simulation parameters
% z: each column corresponds to one time-step of the measurements
%
% Output:
% output: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
[vg,output] = initializationFilter(ps);

for tt = 1:size(z,2)
    ps.propparams.time_step = tt;

    %% propagate particles using prior and estimate the prior covariance matrix for particle flow filters.
    [vg,ps] = propagateAndEstimatePriorCovariance(vg,ps,z(:,tt));

    %% Perform the particle flow step
    vg = particleFlow(vg,ps,z(:,tt));

    output.x_est(:,tt) = vg.xp_m;
     
    %% store the effective number of each time step.
    if isfield(vg,'eff')
        output.Neff(tt) = vg.eff;
    end
end

output.x = ps.x;
output.execution_time = toc;
alg_name = ['PFPF_',ps.setup.pf_type];
calculateErrors(output,ps,alg_name);
end