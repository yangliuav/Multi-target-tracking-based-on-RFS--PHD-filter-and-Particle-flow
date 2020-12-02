function [xp,logW] = GaussianFlow(z,xp1,logW,ps,epsilon0,gamma,tt) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Gaussian flow and weight for each particle according to the paper
% "Bunch, Pete, and Simon Godsill. "Approximations of the optimal importance density using gaussian particle flow importance sampling." arXiv preprint arXiv:1406.3183 (2014)."

% Inputs: 
% z: measurement 
% xp1: the particles after propagation
% logW: the log weights of particles before the flow
% ps: structure with filter and simulation parameters
% epsilon0: initialized epsilon for diffusion term
% gamma: parameter gamma is to control the diffusion degree
% tt: current time step
%
% Outputs:
% xp: samples after propagation and motion
% logW: log weights for all samples
% Written by Lingling Zhao, modified by Yunpeng Li
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vg.xp = xp1;
[dim,N] = size(vg.xp);
vg.M = mean(vg.xp,2);
vg.PP = cov(vg.xp');
vg.xp_m = mean(vg.xp,2);

P0 = cov(vg.xp');
P0_inv = inv(P0);

if size(ps.likeparams.R,3) == 1
    R_inv = inv(ps.likeparams.R);
end

sz = size(z,1);

% sample new epsilon1
epsilon = zeros(dim,N,length(ps.setup.lambda_range)+1);
dw = zeros(dim,N,length(ps.setup.lambda_range));
epsilon(:,:,1) = epsilon0;
for i = 1: dim
    dw(i,:,:) = normrnd(0,sqrt(length(ps.setup.lambda_range)),[N,length(ps.setup.lambda_range)]);
    epsilon(i,:,2:length(ps.setup.lambda_range)+1) = cumsum(dw(i,:,:),1);
end;

previous_lambda = 0;

for k = 1:length(ps.setup.lambda_range),
    lambda = ps.setup.lambda_range(k); 
    delta_lambda = lambda - previous_lambda;
    previous_lambda = lambda;
    HH = ps.likeparams.dh_dx_func(vg.xp,ps.likeparams);  % dh/dx at particle locations: N particles
    h = ps.likeparams.h_func(vg.xp,ps.likeparams);

    ps = updateMeasurementCov(vg.xp,ps);

    % compute P_lambda1 and m_lambda1
    diff_coeff = sqrt( ( 1-exp(-gamma*delta_lambda) ) /delta_lambda);
    drift_coeff = exp(-0.5*gamma*(delta_lambda));
    for particle_ix = 1:N
        
        % if the 3rd dimension of ps.likeparams.R is larger than 1, it
        % means that it depends on the state value and needs to be updated
        % when the particel is updated.
        if size(ps.likeparams.R,3) > 1
            R_inv = inv(ps.likeparams.R(:,:,particle_ix));
        end

       H_i = HH(:,:,particle_ix);
       xp_i = vg.xp(:,particle_ix);
       % Equation (17)
       e = h(:,particle_ix) - H_i * xp_i;
       % Equation (18)
       coeff =  H_i'*R_inv;
       P_lambda1_inv = P0_inv+lambda*coeff*H_i;
       P_lambda0_inv = P0_inv+(lambda-delta_lambda)*coeff*H_i;
       P_lambda1 = inv(P_lambda1_inv); 
       P_lambda0 = inv(P_lambda0_inv); 
       
       % Equation (25)
       % if diff_coeff == 0, which means no diffusion, we do not need to
       % perform calculations related only to the diffusion.
       if diff_coeff~=0
           sqrt_P_lambda1  = sqrtm(P_lambda1);
       else
           sqrt_P_lambda1 = zeros(size(P_lambda1));
       end
       PP_lambda = P_lambda1*P_lambda0_inv;
       drift_P = sqrtm(PP_lambda);
       
       % Equation (18)
       temp1 = P0_inv*xp1(:,particle_ix);
       zc = z - e;
       temp2 = lambda * coeff * zc;
       m_lambda1 = P_lambda1 * (temp1+temp2);
       m_lambda0 = P_lambda0 * (temp1+(lambda - delta_lambda)/lambda*temp2);
       
       % Equation (25)
       drift_v = xp_i - m_lambda0;
       drift = drift_coeff.*drift_P*drift_v;
       diffusion = diff_coeff.*sqrt_P_lambda1*(epsilon(:,particle_ix,k+1)-epsilon(:,particle_ix,k));

       % =======================calculate dx_lambda1/dx_lambda0=========================         
       %============ step2: calculate dm_lambda1/dx_lambda0,j and dm_lambda0/dx_lambda0,j
       % calculate dH/dx_lambda0   
       dH_dx = ps.likeparams.dH_dx_func(xp_i,ps.likeparams);
       
       dm1_dx0 = zeros(size(P_lambda1));
       dm0_dx0 = zeros(size(P_lambda0));
       dP1_dx0 = zeros(dim,dim,dim);
       dP1P0_dx0 = zeros(dim,dim,dim);
       
       A = sqrtm(P_lambda1);
       B = sqrtm(drift_P);
       sqrtdP1_dx0 = zeros(dim,dim,dim);
       sqrtdP1P0_dx0 = zeros(dim,dim,dim);
       
       for j=1:dim
           % Equation (28)
           dm1_dx0(:,j) = lambda*P_lambda1*( dH_dx(:,:,j)*R_inv*( zc-H_i*m_lambda1 ) + H_i'*R_inv*dH_dx(:,:,j)'*( xp_i-m_lambda1 ) );
           dm0_dx0(:,j) = (lambda-delta_lambda)*P_lambda0*( dH_dx(:,:,j)*R_inv*( zc-H_i*m_lambda0 ) + H_i'*R_inv*dH_dx(:,:,j)'* drift_v );

           % After Equation (28)
           %==============step3: calculate dP_lambda1/dx_lambda0,j ======================          
           term1 = dH_dx(:,:,j)*R_inv*H_i + H_i'*R_inv*dH_dx(:,:,j)'; % dim_x * dim_x
           P_lambda1_term1 = P_lambda1*term1;
           dP1_dx0(:,:,j) = -lambda*P_lambda1_term1*P_lambda1;
           dP1P0_dx0(:,:,j) = P_lambda1_term1*((lambda-delta_lambda)*eye(dim)- lambda*P_lambda1*P_lambda0_inv); 

           %===================step4: calculate dx_lambda1/dx_lambda0 according to equation 27   
           %      display('calculate Sylvester equation');
           if diff_coeff~= 0
               sqrtdP1_dx0(:,:,j) = sylvester(A,A,dP1_dx0(:,:,j)); 
           end
           sqrtdP1P0_dx0(:,:,j) = sylvester(B,B,dP1P0_dx0(:,:,j));
       end
      
      %% Equation (27)
      drift_term = dm1_dx0 + drift_coeff*drift_P*(eye(dim) -dm0_dx0);       
      dx1_dx0 = zeros(dim,dim);
      for i = 1:dim
          for j = 1:dim
              diff_term1 = diff_coeff *  sqrtdP1_dx0(i,:,j) * ( epsilon(:,particle_ix,k+1)-epsilon(:,particle_ix,k) );               
              diff_term2 = drift_coeff * sqrtdP1P0_dx0(i,:,j) * drift_v;
              dx1_dx0(i,j) = drift_term(i,j) + diff_term1 + diff_term2 ;
          end
      end
    %            toc
       if det(dx1_dx0)<=0
           w_coeff2 = -inf;
       else
           w_coeff2 = log(det(dx1_dx0)); 
       end

        % Equation (25)
        %   compute new particles  
        xp_i_new = m_lambda1 + drift + diffusion;
        
        vg_new_tmp = [];
        vg_new_tmp.xp = xp_i_new;
        vg_new_tmp.xp_prop_deterministic = xp1(:,particle_ix);
        
        vg_old_tmp.xp = xp_i;
        vg_old_tmp.xp_prop_deterministic = xp1(:,particle_ix);
        w_coeff1 = log_process_density(vg_new_tmp,ps) + lambda*ps.likeparams.llh(xp_i_new,z,ps.likeparams)...
           - log_process_density(vg_old_tmp,ps) - (lambda-delta_lambda)*ps.likeparams.llh(xp_i,z,ps.likeparams);                

      % Equation (26)
        logW(particle_ix) = logW(particle_ix) + w_coeff1  + w_coeff2;
        
        vg.xp(:,particle_ix) = xp_i_new;
    end

    if ps.setup.doplot
       pause(0.1);
       vg.xp_m = particle_estimate(logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate
       ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,['particle flow, \lambda = ',num2str(lambda)]); % call plot function  
    end
end
xp = vg.xp;