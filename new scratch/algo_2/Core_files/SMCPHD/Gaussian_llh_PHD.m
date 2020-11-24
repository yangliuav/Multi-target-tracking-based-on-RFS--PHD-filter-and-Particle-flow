function llh = Gaussian_llh_PHD(xp,z_current,likeparams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

audio = Acoustic_hfuncF1(xp,likeparams);
llh = 0;
minu = bsxfun(@minus,audio,z_current);
llh = llh + exp(loggausspdf(minu,zeros(size(z_current,1),1),likeparams.R));




end

