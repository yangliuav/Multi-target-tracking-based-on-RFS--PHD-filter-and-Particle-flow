function [error_per_trial,ESS_per_trial,avg_execution_time] = plotOneAlgorithmsPerformance(output,ps,plot_settings,alg_ix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the average error metric of the algorithm, as well as ESS (if
% available) and display the execution time.
% 
% Input:
% output: the structure that contains the filtering output
% ps: structure with filter and simulation parameters
% plot_settings: structure with plotting parameters
% alg_ix: a scalar showing the index number of fi
%
% Output:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove the minus sign in the name of tested algorithms
alg_names_all =  fieldnames(output{1});%.algs_executed{alg_ix};
alg_name = alg_names_all{alg_ix};
% alg_name(strfind(alg_name,'-')) = [];

%% extract the tracking error from the output structure.
error_per_step_per_trial = zeros(ps.setup.T,ps.setup.nTrial);
execution_time_per_trial = zeros(1,ps.setup.nTrial);
ESS_per_step_per_trial = zeros(ps.setup.T,ps.setup.nTrial);
    
for trial_ix = 1:ps.setup.nTrial
    output_i = output{trial_ix}.(alg_name);
    error_struct = calculateErrors(output_i,ps);
    
    execution_time_per_trial(trial_ix) = error_struct.execution_time; 
    error_per_step_per_trial(:,trial_ix) = error_struct.error_metric_per_step;
    if isfield(output_i,'Neff')
        ESS_per_step_per_trial(:,trial_ix) = error_struct.Neff(:);
    end
end

%% Plot average error across time
h_fig = figure(1);hold on;
set(h_fig, 'Position', [100, 100, 900, 780]);
[alg_name, 'error: ',num2str(mean(error_per_step_per_trial(:)))]

error_per_step = mean(error_per_step_per_trial,2);
error_per_trial = mean(error_per_step_per_trial,1)';

figure(1);line_fewer_markers(1:ps.setup.T,error_per_step,plot_settings.nMarker,...
    plot_settings.line_types{alg_ix},...
    'Color',plot_settings.line_colors{alg_ix},'MarkerSize',plot_settings.marker_size,'LineWidth',plot_settings.lineWidth);

ESS_per_trial = nan(ps.setup.nTrial,1);
if isfield(output{1}.(alg_name),'Neff')
    h_fig = figure(2);hold on;
    set(h_fig, 'Position', [100, 100, 900, 700]);
    ESS_per_step = mean(ESS_per_step_per_trial,2)';
    ESS_per_trial = mean(ESS_per_step_per_trial,1)';
    disp([alg_name, ', ESS: '  num2str(mean(ESS_per_step))]);
    figure(2);line_fewer_markers(1:ps.setup.T,ESS_per_step,plot_settings.nMarker,...
        plot_settings.line_types{alg_ix},...
        'Color',plot_settings.line_colors{alg_ix},'MarkerSize',plot_settings.marker_size,'LineWidth',plot_settings.lineWidth);
end
avg_execution_time = mean(execution_time_per_trial);

avg_execution_time = round(avg_execution_time'*1e5)*1e-5
end