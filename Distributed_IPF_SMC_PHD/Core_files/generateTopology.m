function G = generateTopology(NumNode,diameter)
% This function implements proposed 
% The implementation code was made by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
% 
% Inputs:
% NumNode: Sensor numbers in network
% diameter: The most distance between 2 connected sensors
% 
% Outputs:
% G: Sensor network topology

%%

while 1
% Generate sysmteric matrix to represent undirected graph
M = randi([0,NumNode],NumNode,NumNode);
M = (M+M')/2;
M = floor(M);
M = M - diag(diag(M));

% Generate matri diagnol setting 0
M(M>diameter) = 0;
G = graph(M);
if det(M) ~= 0 % All nodes in topology must have one neighbor at least
    break;
end
end

end

