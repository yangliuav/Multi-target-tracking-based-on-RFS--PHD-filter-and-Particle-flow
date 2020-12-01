function plot_settings = initializePPF_PlotSettings(ps_initial)

addpath('plotting');

plot_settings.line_types = {'d-','^-','>-','p-','*-','o--','s-','v--','<:','d-','^-','>-','s:','^..'};
plot_settings.line_colors = {'b','r',[0.5 0.5 0.9],'m',[0.7 0.7 0.2],[0.6 0.2 0.6],...
    [0.3 0.6 0.6],[0.2 0.6 0.2],'g','c',[0.3 0.3 0.6],[0.1 0.9 0.6],[0.9 0.2,0.3],[0.5 0.5 0.9]};

plot_settings.nMarker = 20;
plot_settings.lineWidth = 3;
plot_settings.marker_size = 15;

switch ps_initial.setup.example_name
    case 'acoustic_original'
        dimState_per_target = ps_initial.setup.dimState_per_target;

        plot_settings.x_ind = [1:dimState_per_target:dimState_per_target*ps_initial.setup.nTarget]; % x locations
        plot_settings.y_ind = [2:dimState_per_target:dimState_per_target*ps_initial.setup.nTarget]; % y locations   
        plot_settings.z_ind = [3:dimState_per_target:dimState_per_target*ps_initial.setup.nTarget]; % y locations   
end

end