% This function implements proposed 
% The implementation code is written by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:

%% Path
if exist('Result/Groundtrue','dir')==0
    mkdir Result Groundtrue
    for i = 1:20 % model.nAgents
        mkdir(sprintf('Result/Groundtrue/%i',i))
    end
end
addpath(genpath('Result'));
setup.root = pwd;

%%
setup.experiment = 'simulation'; %'real_data' or 'simulation'
if setup.experiment == 'simulation'
    setup.clutter = 2;
end
setup.lambda_range = linspace(0,1,29);
setup.nParticle = 50;
setup.detect  = 0.99;

if setup.experiment == 'simulation'
    inp.ospa_c = 40;
    inp.ospa_p = 1;
    inp.K = 1; % duration of each frame
    inp.T = 20 % number of frames
    inp.H = [1,0,0,0;0,1,0,0]'; % observation matrix for x_pos & y_pos
    inp.nTarget = 4;
    inp.random_seeds = randsample(1e5*inp.nTarget,inp.nTarget);
    inp.survRegion = [0,0,40,40];
    inp.x0 = [12 36 0.001 0.001 32 32 -0.001 -0.005 20 23 -0.1 0.01 35 15 0.002 0.002]'; % target start point
    inp.dimState = 4; % [x_pos,y_pos,x_vel,y_vel]
end
setup.Example = generateExample(inp);

%% 
setup.PHD.P_survival = 0.99;

%% Sensor network Setting
model.nAgent = 20;
model.diameter = 5;
model.G = generateTopology(model.nAgent,model.diameter);
figure(60);
plot(model.G);
title('Sensor Network Topology');
hold on;

% % adjecency matrix of graph G, it shows distance between each agent
% A = (1/(model.nAgent-1))*[ 2 1 0 0 1;
%                             1 2 1 0 0;
%                             0 1 2 0 1;
%                             0 0 0 3 1;
%                             1 0 1 1 1 ];
% D = create_degree(model.nAgent,A);
% [model.neighbor, model.C] = find_neighbor(model.nAgent,A);
% %   Create Laplacian matrix of a graph G
% %   L = D - A
% L = D - A;
% %   Create Weight Matrix
% %   W = I - h*L
% h = 0.2; % constant parameter
% model.W = eye(model.nAgent) - h*L;
% model.gama = 0.9;
% model.iter_range = 50;


%%
out.print_frame = 0;
out.plot_particles = 1;
out.draw_doa_line = 0;
out.save_frame = 1;
out.save_data = 1;

%%
setup.inp = inp;
setup.out = out;
setup.model = model;
clear model;
clear out;
clear inp;