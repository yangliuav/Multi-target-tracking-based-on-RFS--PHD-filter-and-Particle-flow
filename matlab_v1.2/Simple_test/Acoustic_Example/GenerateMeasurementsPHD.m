function [ z_all ] = GenerateMeasurementsPHD(x,c,setup)
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
ps = setup.Ac;
nSensor = ps.likeparams.nSensor;
nTarget = ps.likeparams.nTarget;
nClutter = setup.clutter;
sensorsPos0 = ps.likeparams.sensorsPos([1,size(ps.likeparams.sensorsPos,1)],:);
measvar_real = ps.likeparams.measvar_real;

Amp = ps.likeparams.Amp;
invPow = ps.likeparams.invPow;
d0 = ps.likeparams.d0;


z_all = {};
xx = x(1:4:nTarget*4,:); % x-positions
xy = x(2:4:nTarget*4,:); % y-positions
cx = c(1:4:nClutter*4,:);
cy = c(2:4:nClutter*4,:);
x = [xx;cx;xy;cy];

for tt = 1:ps.setup.T
    xs = x(:,tt); 
    sensorsPos = kron(sensorsPos0,ones(size(xs,1)/2,1));
    rramdon = rand(size(xs,1)/2,size(xs,2));
    idx= rramdon > setup.detect; 
    rramdon(idx)=0;
    idx= rramdon > 0; 
    rramdon(idx)=1;
    r = bsxfun(@minus,sensorsPos,xs);
    r = r.^2;
    r = r(1:(size(xs,1)/2),:)+r((size(xs,1)/2)+1:2*(size(xs,1)/2),:);
    r = sqrt(r);
    r = Amp./ (r.^invPow + d0);
    ii = 1;
    z = zeros(nSensor,sum(rramdon));
    for i = 1 : size(rramdon,1)
        mask = zeros(size(rramdon,1),1);
        mask(i,:) = 1;
        if rramdon(i,1) == 1
            r = sum(r.*mask);
            z(:,ii) = r' + sqrt(measvar_real)*randn(nSensor,1);
            ii = ii+1;
        end
        if ii == sum(rramdon)+1
            ii = 1;
        end
       
    end
    z_all = [z_all,z];


end
    

