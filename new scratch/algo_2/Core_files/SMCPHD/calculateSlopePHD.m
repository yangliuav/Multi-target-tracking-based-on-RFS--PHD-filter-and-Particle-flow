function [slope, log_jacobian_det] = calculateSlopePHD(z_current,vgset,setup,lambda,step_size,Cz)
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
log_jacobian_det = zeros(1,setup.Ac.setup.nParticle);
slope = zeros(2,size(vgset,2));
if lambda >0
    switch setup.pf_type
        case {'ZPF','LEDH'}
            [slope, log_jacobian_det] = homotopy_LocalPHD(z_current,vgset,setup,lambda,step_size);
        case 'EDH'
            slope = homotopy_Mean(z_current,vgset,ps,lambda,step_size);
        case {'NPF'}
            [slope, log_jacobian_det] = NPF_homotopy_PHDV2(z_current,vgset,setup,lambda,step_size,Cz);
        case {'NPFS'}
            [slope, log_jacobian_det] = NPF_single_homotopy_PHDV2(z_current,vgset,setup,lambda,step_size,Cz);
    end
end