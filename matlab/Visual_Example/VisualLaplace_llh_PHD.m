function llh = VisualLaplace_llh_PHD(xp,z_current,likeparams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    d = xp(1:2) - z_current;
    d2 = 2^0.5*(d(1)^2+d(2)^2)/100;
    llh = besselk(0,d2)/pi/10;
end

