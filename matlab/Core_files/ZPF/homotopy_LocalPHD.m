function [slope_real, log_jacobian_det] = homotopy_LocalPHD(z,vgset,setup,lambda,step_size)            
% computes the update for each particle
% using individual gradients at each particle location
%
% Inputs: 
% z: measurement 
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
% lambda: the particle flow time step
% step_size: a scalar that shows the step size.
%
% The computation is as follows (see paper for details)
%
% e = h(x)-Hx;
% 
% A = -0.5*PP*H'*inv(lambda*H*PP*H'+R)*H;
% b = (I + 2*lambda*A)*((I+lambda*A)*PP*H'*inv(R)*(z-e) + A*mX)
%
% slope = Ax + b;
%
% Outputs:
% slope: a struct contains the field real, which includes slopes for vg.xp
%       (the original particles) and the field auxiliary_individual which contains
%        slopes for vg.xp_auxiliary_individual (the slopes for particles used to calculate the slope,
%        used when clustering is not enanled or clustering is performed in each intermediate time step.)
%        and the field auxiliary_cluster: slopes for cluster centroid.
% log_jacobian_det: the log determinant of |I+step_size A^i|, used later in
% weight update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5
    step_size = [];
end
N = size(vgset(1,:),2);
dim = size(vgset(1,1).xp,1);
[zdim,znum] = size(z);
xp_linearization = zeros(4,N);
h = zeros(znum,N);
H = zeros(znum,zdim,N);
for i = 1:N
    xp_linearization(:,i) = vgset(i).xp;
    [~,lm]=max(vgset(i).llh);
    if lm>size(z,2)
        lm =size(z,2);
    end
    vgset(i).z = z(:,lm);
end





log_jacobian_det = ones(1,N);

% Check whether the Jacobian determinant needs to be calculated
boolean_calc_det = 1;

if boolean_calc_det && isempty(step_size)
    error('step size is needed to calculate the Jacobian determinant');
end

%%
A = zeros(dim,dim,N);
b = zeros(dim,N);

slope_auxiliary_individual = zeros(dim,N);

slope_real = zeros(dim,N);
setup.Ac.likeparams.R = [15,0;0,15];
for particle_ix = 1:size(H,3)    
    Hi = [1,0,0,0;0,1,0,0];
    zc =vgset(particle_ix).z;
% Reshape to a [zdim,1,N] matrix to facilitate later computation
    zc = reshape(zc,[zdim,1,size(zc,2)]);

    if size(setup.Ac.likeparams.R,3) > 1na
        Ri = squeeze(ps.likeparams.R(:,:,particle_ix));
    else
        Ri = squeeze(setup.Ac.likeparams.R);
    end
    
    PP_HiTranspose = vgset(particle_ix).PP*Hi';
    A_i = -0.5*PP_HiTranspose*((lambda*Hi*PP_HiTranspose+Ri)\Hi);
    A(:,:,particle_ix) = A_i;
    b(:,particle_ix) = (eye(dim)+2*lambda*A_i)...
        *((eye(dim)+lambda*A_i)*PP_HiTranspose...
        *(Ri\zc)+A_i*vgset(particle_ix).xp_m);
    
    slope_real(:,particle_ix) = A_i*vgset(particle_ix).xp + b(:,particle_ix);
end

% if ps.setup.PFPF
%     if ps.setup.use_cluster
%         slope.auxiliary_cluster = slope_auxiliary_cluster;
%     else
%         slope.auxiliary_individual = slope_auxiliary_individual;
%     end
% end


%%
% if ps.setup.use_cluster
%     %%%%%%%%%%
%     % slope = Ax + b
%     A_full = A(:,:,vg.xp_cluster_ix);
%     b_full = b(:,vg.xp_cluster_ix);
%     
%     log_jacobian_det = log_jacobian_det(vg.xp_cluster_ix);
% 
%     slope.real = zeros(dim,size(A_full,3));
% 
%     for new_particle_ix = 1:size(A_full,3)
%         slope.real(:,new_particle_ix) = A_full(:,:,new_particle_ix)*vg.xp(:,new_particle_ix) + b_full(:,new_particle_ix);
%     end
% end

end