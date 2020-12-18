function log_proposal = log_proposal_density(vg,ps,log_jacobian_det_sum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the log proposal of particles after the flow.
%
% Inputs: 
% vg: structure with working variables: 
% ps: parameter structure
% log_jacobian_det_sum: the sum of the log of Jacobians used to update
% importance weights
%
% Output:
% log_proposal: a vector of log proposals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    log_jacobian_det_sum = zeros(1,size(vg.xp_prop,2));
end

switch ps.setup.example_name
    case 'Septier16'
        log_proposal = computeGH_log_density(vg.xp_prop,vg.xp_prop_deterministic,ps.propparams);
    otherwise
        log_proposal = loggausspdf(vg.xp_prop,vg.xp_prop_deterministic,ps.propparams.Q);
end

log_proposal = log_proposal-log_jacobian_det_sum;