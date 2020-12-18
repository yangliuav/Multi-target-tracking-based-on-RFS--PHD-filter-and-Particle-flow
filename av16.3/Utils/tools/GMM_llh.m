function llh = GMM_llh(xp,z_current,likeparams)

% llh = loggausspdf(bsxfun(@minus,likeparams.h_func(xp,likeparams),z_current),zeros(size(z_current,1),1),likeparams.R);
X = bsxfun(@minus,z_current,likeparams.h_func(xp,likeparams));
y = pdf(likeparams.GMM_obj,X');

llh = log(y');
end

