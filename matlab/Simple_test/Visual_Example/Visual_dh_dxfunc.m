function dhdx = Visual_dh_dxfunc( xp , likeparams )
% Derivative of measurement function for the Acoustic measurement model
% with invpow = 1 
%
% Inputs:
% xp: state value where derivative is evaluated
% 
% likeparams: a structure containg the measurement model parameter values.
%
%  Calculations for the acoustic sensor model 
%
%  r = sqrt[(x1-s1)^2 + (x2-s2)^2]
%  for state position (x1,x2) and sensor position (s1,s2)
%
%  h = Amp/(r+d0)
%  for constants Amp and d0
%
%  dh/dx1 = dh/dr*dr/dx1
%         = -Amp/(r+d0)^2 * 2(x1-s1) * 1/2r
%         = -Amp(x1-s1)/[r(r+d0)^2)
%           

ny = 1;%likeparams.nSensor;

[dim,nParticles] = size(xp);

xx = xp(1,:);
xy = xp(2,:);

x = [xx;xy];


if nParticles>1
    dhdx = zeros(ny,dim,nParticles);

    % mv = x-s
    mv = bsxfun(@minus,permute(x,[1 3 2]),likeparams.sensorsPos);
    v = mv.^2;

    % v = (x1-s1)^2 + (x2-s2)^2 for each target
    v(1:likeparams.nTarget,:,:) = v(1:likeparams.nTarget,:,:)+v(likeparams.nTarget+1:2*likeparams.nTarget,:,:);
    v(likeparams.nTarget+1:2*likeparams.nTarget,:,:) = v(1:likeparams.nTarget,:,:);

    % v = r (as defined above)
    v = sqrt(v);
    v = likeparams.Amp./ (((v+likeparams.d0).^2).*v);    
    v = -permute(v.*mv,[2 1 3]);

    dhdx(:,1:4:likeparams.nTarget*4,:) = v(:,1:likeparams.nTarget,:);
    dhdx(:,2:4:likeparams.nTarget*4,:) = v(:,likeparams.nTarget+1:2*likeparams.nTarget,:);

else
    dhdx = zeros(ny,dim);
    % mv = x-s
    mv = bsxfun(@minus,x,likeparams.sensorsPos);
    v = mv.^2;

    v(1:likeparams.nTarget,:) = v(1:likeparams.nTarget,:)+v(likeparams.nTarget+1:2*likeparams.nTarget,:);
    v(likeparams.nTarget+1:2*likeparams.nTarget,:) = v(1:likeparams.nTarget,:);

    v = sqrt(v);
    v = -likeparams.Amp./ (((v+likeparams.d0).^2).*v);

    v = (v.*mv)';
    
    dhdx(:,1:4:likeparams.nTarget*4) = v(:,1:likeparams.nTarget);
    dhdx(:,2:4:likeparams.nTarget*4) = v(:,likeparams.nTarget+1:2*likeparams.nTarget); 
end


