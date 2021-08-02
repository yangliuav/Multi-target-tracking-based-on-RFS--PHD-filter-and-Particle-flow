function D = create_degree(nAgent, A)
% This function implements degree matrix creation
% The implementation code is written by Peipei Wu
% @ June 2021, University of Surrey
%   Create Degree Matrix
%   dii = sum_1^n (a_ij) = sum_1^n (a_ji)

D = zeros(nAgent);
for i = 1:nAgent
    for j = 1:nAgent
        D(i,i) = D(i,i) + A(i,j);
    end
end
% D is degree matrix
end

