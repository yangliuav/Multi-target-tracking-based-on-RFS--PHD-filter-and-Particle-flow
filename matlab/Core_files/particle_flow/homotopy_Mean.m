function slope = homotopy_Mean(z,vg,ps,lambda,step_size) 
% computes the update for each particle
% using a single gradient calculated at the mean
%
% Inputs: 
% z: measurement 
% vg: a struct that contains the filter output
% ps: a struct with filter and simulation parameters
% lambda: the particle flow time step
%
% The computation is as follows (see paper for details)
%
% e = h(x)-Hx;
%
% A = -0.5*PP*H'*inv(lambda*H*PP*H'+R)*H;
% b = (I + 2*lambda*A)*((I+lambda*A)*PP*H'*inv(R)*(z-e) + A*mX)
% 
% Outputs:
% slope: a struct contains the field real, which includes slopes for vg.xp
%        and field auxiliary_mean, which contains slopes for vg.xp_m
%
[dim,N] = size(vg.xp);

% to ensure one-to-one mapping of EDH, we use a deterministic flow starting
% from the prior mean to calculate the slope.
% Although it is named vg.xp_auxiliary_individual, it is a prior mean.
if ps.setup.PFPF
    vg.xp_m = vg.xp_auxiliary_individual;
end

% Calculate the error term due to linearization at the mean
% and subtract it from the measurement vector
%
H = ps.likeparams.dh_dx_func(vg.xp_m,ps.likeparams);  % dh/dx at mean
h = ps.likeparams.h_func(vg.xp_m,ps.likeparams); % h at mean
e = h - H*vg.xp_m; % error term

zc = bsxfun(@minus,z,e);

S = vg.PP*H';
A = -0.5*S*((lambda*H*S+ps.likeparams.R)\H);

% Compute b
b = (eye(dim,dim)+2*lambda*A)*((eye(dim,dim)+lambda*A)*S*(ps.likeparams.R\zc)+A*vg.mu_0);
% 
% if  step_size >= 1/max(abs(real(eig(A))));
%     error('the eigenvalues cannot be equal to the step size');
% end
    
% Calculate slope
slope.real = A*vg.xp + b*ones(1,N); % d by N

if ps.setup.PFPF
    slope.auxiliary_individual = A*vg.xp_m+b;
else
    slope.auxiliary_individual = [];
end

