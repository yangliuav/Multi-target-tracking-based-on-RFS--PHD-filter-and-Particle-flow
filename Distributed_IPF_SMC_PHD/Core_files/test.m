% xp = [7.5012
%     7.5617
%     3.4274
%     9.2751
%     5.6256
% ]
% 
% model.nAgent = 5;
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
% 
% xp = consensus_filter(xp,model)

% data1 = [16.262265541347016,16.782115769452098,30.758586504712860;
%     11.464617914092461,33.955067584287290,30.066543824213640]
% 
% data2 = [15.640857592500339,16.961565881023370,31.322039827129470;
%     10.799215144734399,33.874319662828675,31.748051622653623]
% 
% data3 = [15.387387556185402,16.874178310937960,30.445872440192066;
%     10.633277712634923,35.610772680363940,28.235404743662480]
% 
% data4 = [14.994662385885817,15.249545144948685,29.702781511614740;
%     34.840690076405890,12.391196861441175,29.416965178764507]
% 
% data5 = [10.515166961248320,16.249898998898498,20.355358873022170,32.184130320622636;
%     7.905746224258998,33.182264892859040,15.115481706484985,30.523089338978902]
% a = [data1;data2;data3;data4]
% [ia,ja] = size(a)
% [i5,j5] = size(data5)
% zero = zeros(ia,1)
% a = [a zero]
% a = [a;data5]
% 
% for i = 1:5
%     if i ~= 5
%         sensor{i}.update = a((i*2-1):(i*2),:)
% %     else
% %         sensor{i}.update = a((i*2-1):end,:)
%     end
% end
xp = [7.5012 7.5617]
normpdf(xp,2)
