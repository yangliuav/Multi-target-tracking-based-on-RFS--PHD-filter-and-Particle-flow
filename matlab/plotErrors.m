function plotErrors(file_name)
% Calculating filtering errors and display them
% 
% Input:
% file_name: a string specifying the location of the filter output,
%            which is stored in the 'Results' folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except file_name;
clc;close all;

addpath('plotting');
addpath('tools');
addpath('Results');

load(file_name);

%% Initialize plot settings.
plot_settings = initializePPF_PlotSettings(ps);

%% display each algorithm's performance
error_per_trial_per_alg = zeros(ps.setup.nTrial,length(ps.setup.algs_executed));
ESS_per_trial_per_alg = zeros(ps.setup.nTrial,length(ps.setup.algs_executed));
execution_time_per_alg = zeros(length(ps.setup.algs_executed),1);

for alg_ix = 1:length(fieldnames(output{1}))
    [error_per_trial_per_alg(:,alg_ix),ESS_per_trial_per_alg(:,alg_ix),execution_time_per_alg(alg_ix)] = ...
        plotOneAlgorithmsPerformance(output,ps,plot_settings,alg_ix);
end
addFigureProperties(ps);

performBoxplot(error_per_trial_per_alg,ps);