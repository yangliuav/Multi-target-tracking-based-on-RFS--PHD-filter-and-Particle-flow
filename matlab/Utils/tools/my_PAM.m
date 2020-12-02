function [idx,medoid_indices] = my_PAM(dist_mat,ps)            
% Find the clusters based on weighted combinations of the Euclidean
% distances between particles and Pearson correlation coefficients between
% slopes.
%
% Inputs: 
% dist_mat: an nParticle-by-nParticle matrix containing weighted distances between each
% particle
% ps: structure with filter and simulation parameters
%
% Output:
% idx: an nParticle-by-1 vector idx containing cluster indices of each
% particle
% medoid_indices: an nCluster-by-1 idx containing index of cluster medoids

nParticle = ps.setup.nParticle;
nCluster =ps.setup.nParticleCluster;

%% initialization: randomly select (without replacement) k of the n data points as the medoids
medoid_indices = randperm(nParticle,nCluster);

continue_build_swap  = true;

while continue_build_swap
    medoid_indices_old = medoid_indices;
    %% The build step: associate each data point to the closest medoid.
    distance_to_medoids = dist_mat(:,medoid_indices);
    [~,idx] = min(distance_to_medoids,[],2);

    %% The swap step: for each medoid m, for each non-medoid data point o:
    for cluster_ix = 1:nCluster
        points_indices_in_cluster_i = find(idx==cluster_ix);
        medoid_ix = medoid_indices(cluster_ix);
        sum_distance_old = sum(dist_mat(points_indices_in_cluster_i,medoid_ix));

        % Within each cluster, each point is tested as a potential medoid
        % by checking if the sum of within-cluster distances gets smaller using that point as the medoid.
        for ix = 1:length(points_indices_in_cluster_i)
            point_ix = points_indices_in_cluster_i(ix);
            if point_ix == medoid_ix
                continue;
            end

            sum_distance_new = sum(dist_mat(points_indices_in_cluster_i,point_ix));

            % If so, the point is defined as a new medoid. Every point is then assigned to the cluster with the closest medoid.
            if sum_distance_new < sum_distance_old
                sum_distance_old = sum_distance_new;
                medoid_ix = point_ix;
            end       
        end

        medoid_indices(cluster_ix) = medoid_ix;
    end
    
    if isequal(medoid_indices,medoid_indices_old)
        continue_build_swap = false;
    end
end