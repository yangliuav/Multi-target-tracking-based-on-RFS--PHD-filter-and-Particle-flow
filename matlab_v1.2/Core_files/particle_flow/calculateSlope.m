function [slope, log_jacobian_det] = calculateSlope(z_current,vg,ps,lambda,step_size)
% Calculate the slopes of each particle during the particle flow.
%
% Input:
% z_current: a column vector of the measurements at the current time step.
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
% lambda: a scalar in [0,1] that indicates the psuedo-time of the flow
% step_size: a scalar that shows the step size.
%
% Output:
% slope: a matrix of size dim x nParticle that contains the slopes of each particle during the flow.
% log_jacobian_det: a row vector containing the log of Jacobian determinants for
%               each particle that are used in the proposal calculation.
%%%%%%%%%%%%%%%%%
log_jacobian_det = zeros(1,ps.setup.nParticle);

switch ps.pf_type
    case {'SMC','LEDH'}
        [slope, log_jacobian_det] = homotopy_Local(z_current,vg,ps,lambda,step_size);
    case 'EDH'
        slope = homotopy_Mean(z_current,vg,ps,lambda,step_size);
end