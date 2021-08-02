function [N,C] = find_neighbor(nAgent,A)
%   neighborhood model of agent i, N(i) = {j in V and (i,j) in E}
%   first collect matrix N for neighbors
%   then collect matrix C

N = {};
for i = 1:nAgent
    tN = [];
    for j = 1:nAgent % make sure j is in V 
        if i == j % No self loop in this algorithm
            continue
        end
        if A(i,j) % check E(i,j) exisited or not (no need to check E(j,i) due to undirected)
            tN = [tN,j];
        end
        N{i} = tN;
    end
end
% N is neighbor matrix

c = rref(A);
for i = 1:nAgent
    n = N{i};
    nc = [];
    for j = 1:size(n,2)
        nc = [nc c(:,n(j))];
    end
    nc = [nc c(:,i)];
    C{i} = nc';
end

% C is matrix C

end

