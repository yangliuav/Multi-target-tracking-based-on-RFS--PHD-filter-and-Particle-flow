function [ z_all,idx_all ] = VisualGenerateMeasurementsPHD(x,c,setup)
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

nTarget = ps.likeparams.nTarget;
nClutter = setup.clutter;

measvar_real = ps.likeparams.measvar_real;

Amp = ps.likeparams.Amp;
invPow = ps.likeparams.invPow;
d0 = ps.likeparams.d0;

z_all ={};
xx = x(1:4:nTarget*4,:); % x-positions
xy = x(2:4:nTarget*4,:); % y-positions
cx = c(1:4:nClutter*4,:);
cy = c(2:4:nClutter*4,:);
x = [xx;cx;xy;cy];
idxall = {};
for tt = 1:ps.setup.T
    xs = x(:,tt); 
    rramdon = rand(size(xs,1)/2,size(xs,2));
    idx=find(rramdon > setup.PHD.P_detect ); %setup.detect
    idx = []; % all detect
    for i = 1:size(idx,1)
       xs(idx(i,1),1) = setup.Ac.likeparams.simAreaSize*rand;
       xs(idx(i,1) + size(xs,1)/2,1) = setup.Ac.likeparams.simAreaSize*rand;
    end
    idxall = [idxall,idx]; 
    rramdon(idx)=0;
    idx=find(rramdon > 0); 
    rramdon(idx)=1;
    
    z = zeros(ps.setup.dimState_per_target/2,size(xs,1)/2);
      
    for i = 1 : size(xs,1)/2
      z(:,i) = xs([i,i+size(xs,1)/2],:)+ sqrt(measvar_real)*randn(ps.setup.dimState_per_target/2,1);
    end
    z_all = [z_all,z];
end
    

