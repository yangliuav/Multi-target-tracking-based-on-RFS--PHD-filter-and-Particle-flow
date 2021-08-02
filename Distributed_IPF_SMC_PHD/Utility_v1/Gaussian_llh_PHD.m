function llh = Gaussian_llh_PHD(xp,z_current,likeparams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

audio = xp(1:2,:);
llh = 0;
minu = bsxfun(@minus,audio,z_current);
m = minu(1)^2 + minu(2)^2;
m = m^(1/2);
llh = sum(normpdf(m,0,3));


end

