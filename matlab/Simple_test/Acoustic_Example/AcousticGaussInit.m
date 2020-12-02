function [xp,m0,P0] = AcousticGaussInit(ps, nParticle )
% Generates an initial particle distributions 
% according to a multivariate Gaussian with diagonal covariance matrix
% (common variance terms)
% parameters are specified in the structure initparams: 
% mean x0, variance sigma0 and dimension dim

initparams = ps.initparams;
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

% xp = unifrnd([0;0],[initparams.simAreaSize;initparams.simAreaSize],nParticle,1);
P0 = diag(sigma0.^2);

xp = m0*ones(1,nParticle)+ bsxfun(@times,sigma0,randn(dim,nParticle));

end

