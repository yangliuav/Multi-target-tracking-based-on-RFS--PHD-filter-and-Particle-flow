function [slope, log_jacobian_det] = homotopy_Local(z,vg,ps,lambda,step_size)            
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

[dim,N] = size(vg.xp);
zdim = size(z,1);

% xp_linearization is where the linearization and the slope
% of the flow is calculated.
if ps.setup.PFPF
    if ps.setup.use_cluster
        xp_linearization = vg.xp_auxiliary_cluster;
    else
        xp_linearization = vg.xp_auxiliary_individual;
    end        
else
    xp_linearization = vg.xp;
end
% Calculate the error term due to linearization
% and subtract it from the measurement vector
% This results in a [zdim,N] matrix, since the linearization and measurement evaluation is at each
% particle location. 
%
H = ps.likeparams.dh_dx_func(xp_linearization,ps.likeparams);  % dh/dx at particle locations zdim x dim x N particles
h = ps.likeparams.h_func(xp_linearization,ps.likeparams);
e = zeros(size(h));
for particle_ix = 1:size(h,2)
    e(:,particle_ix) = h(:,particle_ix)-H(:,:,particle_ix)*xp_linearization(:,particle_ix);
end

zc = bsxfun(@minus,z,e);
% Reshape to a [zdim,1,N] matrix to facilitate later computation
zc = reshape(zc,[zdim,1,size(zc,2)]);

log_jacobian_det = ones(1,size(H,3));

% Check whether the Jacobian determinant needs to be calculated
boolean_calc_det = ps.setup.PFPF && ~isempty(strfind(ps.setup.pf_type,'LEDH'));

if boolean_calc_det && isempty(step_size)
    error('step size is needed to calculate the Jacobian determinant');
end

%%
A = zeros(dim,dim,size(H,3));
b = zeros(dim,size(H,3));

if ps.setup.use_cluster
    slope_auxiliary_cluster = zeros(dim,size(H,3));
else
    slope_auxiliary_individual = zeros(dim,N);
end

slope_real = zeros(dim,N);

for particle_ix = 1:size(H,3)    
    Hi = squeeze(H(:,:,particle_ix));
    
    if size(ps.likeparams.R,3) > 1
        Ri = squeeze(ps.likeparams.R(:,:,particle_ix));
    else
        Ri = squeeze(ps.likeparams.R);
    end
    
    PP_HiTranspose = vg.PP*Hi';
    A_i = -0.5*PP_HiTranspose*((lambda*Hi*PP_HiTranspose+Ri)\Hi);
    A(:,:,particle_ix) = A_i;
    b(:,particle_ix) = (eye(dim)+2*lambda*A_i)...
        *((eye(dim)+lambda*A_i)*PP_HiTranspose...
        *(Ri\zc(:,1,particle_ix))+A_i*vg.mu_0);
    
    if ps.setup.PFPF
        if ps.setup.use_cluster
            slope_auxiliary_cluster(:,particle_ix) = ...
                A_i*xp_linearization(:,particle_ix)+b(:,particle_ix);
        else
            slope_auxiliary_individual(:,particle_ix) = ...
                A_i*xp_linearization(:,particle_ix) + b(:,particle_ix);
        end
    end
    
    if ~ps.setup.use_cluster
        slope_real(:,particle_ix) = A_i*vg.xp(:,particle_ix) + b(:,particle_ix);
    end
    
    if boolean_calc_det
        log_jacobian_det(particle_ix) = log(abs(det(eye(dim)+step_size*A_i)));
    end
%     if  step_size >= 1/max(abs(real(eig(A_i))));
%         error('the eigenvalues cannot be equal to the step size');
%     end
end

if ps.setup.PFPF
    if ps.setup.use_cluster
        slope.auxiliary_cluster = slope_auxiliary_cluster;
    else
        slope.auxiliary_individual = slope_auxiliary_individual;
    end
end

slope.real = slope_real;

%%
if ps.setup.use_cluster
    %%%%%%%%%%
    % slope = Ax + b
    A_full = A(:,:,vg.xp_cluster_ix);
    b_full = b(:,vg.xp_cluster_ix);
    
    log_jacobian_det = log_jacobian_det(vg.xp_cluster_ix);

    slope.real = zeros(dim,size(A_full,3));

    for new_particle_ix = 1:size(A_full,3)
        slope.real(:,new_particle_ix) = A_full(:,:,new_particle_ix)*vg.xp(:,new_particle_ix) + b_full(:,new_particle_ix);
    end
end

end