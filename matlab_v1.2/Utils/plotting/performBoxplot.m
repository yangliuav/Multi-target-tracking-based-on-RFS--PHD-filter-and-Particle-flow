function performBoxplot(error_per_trial_per_alg,ps)
%% Create boxplots of errors per trial, for each algorithm
% Input:
% error_per_trial_per_alg: an m x n matrix where m is the number of trials
%                          and n is the number of algorithms tested.
% ps: a struct that contains the simulation and filter parameter values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alg_names = ps.setup.algs_executed;
            
ps.setup.fontSize = .8*ps.setup.fontSize;

figure;
bh = boxplot(error_per_trial_per_alg);

switch ps.setup.example_name
    case {'Acoustic','acoustic_original'}
        ylabel('OMAT error (m)','FontSize',ps.setup.fontSize);
    otherwise
        ylabel('MSE','FontSize',ps.setup.fontSize);
end

for i = 1:size(bh,2)
    text(i-.5,mod(i,2)*2/3-1.5,alg_names{i},'FontSize',ps.setup.fontSize);
    set(bh(:,i),'linewidth',3);
end

set(gca,'FontSize',ps.setup.fontSize);
set(gcf, 'Position', [0, 0, 600,800]);
set(gca,'XTickLabel',{''});
set(gcf,'color','w');
set(gcf, 'Position', [0, 0, 600,800]);