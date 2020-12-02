function [ z ] = generateGaussianMeasurements(ps)
% Generates target trajectories for the 4-target acoustic sensor example
%
% Input: parameter structure, including states and measurement model
% parameters
%
% Output: measurements (no_sensors, T)
%
%  Calculations for the acoustic sensor model 
%
%  r = sqrt[(x1-s1)^2 + (x2-s2)^2]
%  for state position (x1,x2) and sensor position (s1,s2)
%
%  h = sum (Amp/(r^invPow+d0))
%  for constants Amp,d0, and invPow

x = ps.x;

dimMeasurement_all = ps.likeparams.dimMeasurement_all;

z = zeros(dimMeasurement_all,ps.T);

for tt = 1:ps.T
    x_current = x(:,tt); % x-positions
    z_current = ps.h_func(x_current, ps.likeparams);
    z(:,tt) = mvnrnd(z_current',ps.likeparams.R);
end;
    

