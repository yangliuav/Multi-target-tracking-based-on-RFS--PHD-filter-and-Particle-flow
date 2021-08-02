function [xp,m0,P0] = GaussInit(example,nParticle)
% This function implements proposed IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
%
%
% Inputs:
% ps: example
% nParticle: number of particles
%
% Output:
% xp: particles state
% m0: mean (target position)
% P0: update covariance

%%
initparams = example.initparams;
sigma0 = initparams.sigma0;
x0 = initparams.x0;
dim = size(x0,1);
area =initparams.survRegion;
out_of_bound = true;
while out_of_bound
    m0= x0+sigma0.*randn(dim,1);
    
    x_pos_ix = 1:4:dim;
    y_pos_ix = 2:4:dim;
    if ~(nnz(m0(x_pos_ix) < area(1)) || nnz(m0(y_pos_ix) < area(2))...
            || nnz(m0(x_pos_ix) > area(3)) || nnz(m0(y_pos_ix) > area(4)))
        out_of_bound = false;
    end
end

P0 = diag(sigma0.^2);

xp = m0*ones(1,nParticle)+ bsxfun(@times,sigma0,randn(dim,nParticle));

end

