function [ z_all,idx_all ] = VisualGenerateMeasurementsPHD(x,c,args)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generates target trajectories for the 4-target acoustic sensor example
%
% Input: parameter structure, including states and measurement model
% parameters
% x: GT
% c: Clutters
% args: setup, always setup.Ac useful
%
% Output: measurements (no_sensors, T)
% z_all: detect
% idx_all: check detect missing? but not shown here
%
%  Calculations for the acoustic sensor model 
%
%  r = sqrt[(x1-s1)^2 + (x2-s2)^2]
%  for state position (x1,x2) and sensor position (s1,s2)
%
%  h = sum (Amp/(r^invPow+d0))
%  for constants Amp,d0, and invPow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps = args.Example;

nTarget = ps.likeparams.nTarget;
nClutter = args.clutter;

measvar_real = ps.likeparams.measvar_real;

% Amp = ps.likeparams.Amp;
% invPow = ps.likeparams.invPow;
% d0 = ps.likeparams.d0;

z_all ={};
% GT
xx = x(1:4:nTarget*4,:); % x-positions
xy = x(2:4:nTarget*4,:); % y-positions
% Clutter
cx = c(1:4:nClutter*4,:);
cy = c(2:4:nClutter*4,:);
x = [xx;cx;xy;cy];
idxall = {};

for tt = 1:ps.T
    xs = x(:,tt);
    
    % this part check detect successfully or not
    % due to all detect, this part useless
%     rramdon = rand(size(xs,1)/2,size(xs,2));
%     idx=find(rramdon > args.PHD.P_detect ); %setup.detect
%     idx = []; % all detect
%     for i = 1:size(idx,1)
%        xs(idx(i,1),1) = args.Ac.likeparams.simAreaSize*rand;
%        xs(idx(i,1) + size(xs,1)/2,1) = args.Ac.likeparams.simAreaSize*rand;
%     end
%     idxall = [idxall,idx]; 
%     rramdon(idx)=0;
%     idx=find(rramdon > 0); 
%     rramdon(idx)=1;
    
    z = zeros(ps.dimState/2,size(xs,1)/2); % detect position
      
    for i = 1 : size(xs,1)/2
      z(:,i) = xs([i,i+size(xs,1)/2],:)+ sqrt(measvar_real)*randn(ps.dimState/2,1);
    end
%   format of z      
%   z=[zx1,zx2,zx3,zx4,zcx1,zcx2;
%      zy1,zy2,zy3,zy4,zcy1,zcy2]
    z_all = [z_all,z];
end
    

