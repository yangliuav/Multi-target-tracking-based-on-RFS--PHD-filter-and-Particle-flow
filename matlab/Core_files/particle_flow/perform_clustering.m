function vg = perform_clustering(z,vg,ps,lambda)            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform clustering of particles generated without dyanmic noise.
%
% Inputs: 
% z: measurement 
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
% lambda: particle flow psuedo-time.
%
% Output:
% vg: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dist_mat_combined = calculateDistanceCombined(z,vg,ps,lambda);

[vg.xp_cluster_ix, medoid_indices] = my_PAM(dist_mat_combined,ps);

vg.xp_auxiliary_cluster = vg.xp_auxiliary_individual(:,medoid_indices);
end