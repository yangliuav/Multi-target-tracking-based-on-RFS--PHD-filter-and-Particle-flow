function dist_mat_combined = calculateDistanceCombined(z,vg,ps,lambda)
% Find the clusters based on weighted combinations of the Euclidean
% distances between particles and Pearson correlation coefficients between
% slopes.
%
% Inputs: 
% xp: an nParticle-by-state_dim matrix. 
% slope: an nParticle-by-state_dim matrix. 
% ps: structure with filter and simulation parameters
%
% Output:
% dist_mat_combined: an nParticle-by-nParticle matrix containing weighted distances between each
% particle

[dim,N] = size(vg.xp);
zdim = size(z,1);

xp = vg.xp_auxiliary_individual;
nParticle = ps.setup.nParticle;
weight_euclidean = ps.setup.weight_euclidean;

%% Calculate the Euclidean distances
dist_vec_euclidean = pdist(xp');
% scale the distances to be in the range [0 2]
dist_vec_euclidean = 2*(dist_vec_euclidean - min(dist_vec_euclidean))/range(dist_vec_euclidean);

%%
%% Calculate the slope 
% Calculate the error term due to linearization
% and subtract it from the measurement vector
% This results in a [zdim,N] matrix, since the linearization and measurement evaluation is at each
% particle location. 
%
H = ps.likeparams.dh_dx_func(xp,ps.likeparams);  % dh/dx at particle locations zdim x dim x N particles
h = ps.likeparams.h_func(xp,ps.likeparams);
e = zeros(size(h));
for particle_ix = 1:N
    e(:,particle_ix) = h(:,particle_ix)-H(:,:,particle_ix)*xp(:,particle_ix);
end

zc = bsxfun(@minus,z,e);
% Reshape to a [zdim,1,N] matrix to facilitate later computation
zc = reshape(zc,[zdim,1,size(zc,2)]);


%%
A = zeros(dim,dim,N);
b = zeros(dim,N);

slope = zeros(dim,N);

for particle_ix = 1:size(H,3)
    Hi = squeeze(H(:,:,particle_ix));
    
    if size(ps.likeparams.R,3) > 1
        Ri = squeeze(ps.likeparams.R(:,:,particle_ix));
    else
        Ri = squeeze(ps.likeparams.R);
    end
    
    PP_HiTranspose = vg.PP*Hi';
    A_i = squeeze(-0.5*PP_HiTranspose*((lambda*Hi*PP_HiTranspose+Ri)\Hi));
    A(:,:,particle_ix) = A_i;
    b(:,particle_ix) = (eye(dim)+2*lambda*A_i)...
        *((eye(dim)+lambda*A_i)*PP_HiTranspose...
        *(Ri\zc(:,1,particle_ix))+A_i*vg.mu_0);
    
    slope(:,particle_ix) = A_i*xp(:,particle_ix)+b(:,particle_ix);
end

% Calculate the Pearson correlation coefficients between slopes
dist_vec_slope = pdist(slope','correlation');

%% Calculate the mixed distance.
dist_vec_combined = weight_euclidean*dist_vec_euclidean + (1-weight_euclidean)*dist_vec_slope;

dist_mat_combined = zeros(nParticle);
dist_mat_combined(tril(ones(nParticle),-1)==1) = dist_vec_combined;
dist_mat_combined = dist_mat_combined + dist_mat_combined';

end