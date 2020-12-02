function error_struct = calculateErrors(output,ps,alg_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the error metrics
%
% Input:
% output: a struct that contains the filter output
% ps: a struct that contains the parameter settings of the filters and
% simulations.
% alg_name: a string containing the algorithm name
%
% Output:
% error_struct: a struct that contains the error metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_error = true;

if nargin < 3
    display_error = false;
end

error_struct.error_metric_per_step = zeros(1,size(output.speakerx,2));

for tt = 1:size(output.x_est,2)
    switch ps.setup.example_name
        case {'Acoustic'}
            estimted_states = reshape(output.x_est(:,tt),size(output.x_est,1)/ps.setup.nTarget,ps.setup.nTarget);
            estimated_tracks = estimted_states(1:2,:);
            true_states = reshape(output.x(:,tt),size(output.x_est,1)/ps.setup.nTarget,ps.setup.nTarget);
            true_tracks = true_states(1:2,:);
            error_struct.error_metric_per_step(tt) = ospa_dist(estimated_tracks,true_tracks,ps.setup.ospa_c,ps.setup.ospa_p);
        case {'Septier16'}
            estimted_states = real(output.x_est(:,tt));
            true_states = output.x(:,tt);
            error_struct.error_metric_per_step(tt) = mean((estimted_states-true_states).^2);
        otherwise
            error('not supported simulation setup')
    end
end

error_struct.execution_time = output.execution_time;
if isfield(output,'Neff')
    error_struct.Neff = output.Neff;
end

if display_error&&isfield(ps,'trial_ix')
    disp(['Trial ', num2str(ps.trial_ix),...
        ': Average Error: ',num2str(mean(error_struct.error_metric_per_step)),...
        ', Computation Time: ',num2str(mean(error_struct.execution_time)),...
        ', ', alg_name])
end