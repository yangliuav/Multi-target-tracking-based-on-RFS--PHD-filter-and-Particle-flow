function [ z ] = GenerateMeasurements(x,ps)
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

nSensor = ps.likeparams.nSensor;
nTarget = ps.likeparams.nTarget;
sensorsPos = ps.likeparams.sensorsPos;
measvar_real = ps.likeparams.measvar_real;

Amp = ps.likeparams.Amp;
invPow = ps.likeparams.invPow;
d0 = ps.likeparams.d0;

z = zeros(nSensor,ps.setup.T);

xx = x(1:4:nTarget*4,:); % x-positions
xy = x(2:4:nTarget*4,:); % y-positions

x = [xx;xy];

for tt = 1:ps.setup.T
    
    xs = x(:,tt); 
    
    r = bsxfun(@minus,sensorsPos,xs);
    
    r = r.^2;
    r = r(1:nTarget,:)+r(nTarget+1:2*nTarget,:);
    r = sqrt(r);
    
    r = sum(Amp./ (r.^invPow + d0));
    
    z(:,tt) = r' + sqrt(measvar_real)*randn(nSensor,1);
end;
    

