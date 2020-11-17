function X= gen_phistate_intensity_vk(model,old_X)
% This function generates particles from spawned and surviving particles.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% model     -   variables used in the phd filtering.
% old_X     -   particles from previous step.
% =========================================================================
% Output:
% X         -   particle set with recently generated particles.
% =========================================================================

L_s             =   length(model.lambda_s); 
[nx,num_par]    =   size(old_X);
sum_term        =   sum(model.lambda_s)+ (1-model.P_death);

temp            =   rand(num_par,1);
threshold       =   0;
X               =   zeros(nx,num_par);
%spawn
for i=1:L_s
    threshold   =   threshold+ model.lambda_s(i)/sum_term;
    idx         =   find(temp <= threshold);
    X(:,idx)    =   repmat(model.chk_x(:,i),[1 length(idx)])+ ...
                    model.chk_F(:,:,i)*old_X(:,idx)+ ...
                    model.sigma_s(i)*sqrt(model.Q)*randn(size(model.Q(:,:),2),length(idx));
    temp(idx)   =   1.1;
    
   
end;
%survived
idx         =   find(temp <= 1);
X(:,idx)    =   model.F*old_X(:,idx)+ sqrt(model.Q)*randn(size(model.Q,2),length(idx));


%checks input coordinates whether inside the limits
X(1,:)  =   round(cap(X(1,:), 1, model.posn_interval(1,2)));
X(3,:)  =   round(cap(X(3,:), 1, model.posn_interval(3,2)));
