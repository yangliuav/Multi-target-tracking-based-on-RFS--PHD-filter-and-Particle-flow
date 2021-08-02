function node = flooding(node)
% This function implements proposed Distribtued IPF-SMC-PHD algorithm
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:

%%
N = size(node,2);
idxNode = 1:N;
while N
    for j = idxNode
        n = node{j};
        % recieve & seen information check
        n.incoming = []; % new incoming information
        if n.t ~= 1
            if ~isempty(n.seen)
                if isempty(n.recieve)
                    idxNode(idxNode == j) = [];
                    N = N - 1;
                    continue
                end
                [~,idx] = setdiff(n.recieve(:,1), n.seen(:,1));
                for i = idx
                    if n.recieve(i,1) == j
                        idx(idx == i) = [];
                        continue
                    end
                    n.incoming = [n.incoming;n.recieve(i,:)];
                end
                n.seen = [n.seen; n.incoming];
            else
                [~,idx] = setdiff(n.recieve(:,1), n.idx);
                for i = idx
                    if n.recieve(i,1) == j
                        idx(idx == i) = [];
                        continue
                    end
                    n.incoming = [n.incoming;n.recieve(i,:)];
                end
                n.seen = n.incoming;
            end
            n.recieve = [];
        end    
        % check DoC reach treshold or not
        if n.DoC > 0.5%treshold
            idxNode(idxNode == j) = [];
            N = N - 1;
            continue
        end
        % send
        if n.t == 1
            neighbor = n.neighbor;
            for id = neighbor
                node{id}.recieve = [node{id}.recieve; [n.idx,n.info]]; % ID to idx
            end
            n.t = n.t + 1; 
            n.sent = [n.sent;[n.idx,n.info]];
        else
            neighbor = n.neighbor;
            for id = neighbor
                node{id}.recieve = [node{id}.recieve; n.incoming];
            end
            n.t = n.t + 1; 
            n.sent = [n.sent;n.incoming];
        end
        % calculate DoC
        n.DoC = (size(n.seen,1) - 1)/(20 - 1);
        node{j} = n;
    end
end

end

