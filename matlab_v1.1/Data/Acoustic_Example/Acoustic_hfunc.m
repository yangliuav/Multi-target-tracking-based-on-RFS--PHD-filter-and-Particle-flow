function y = Acoustic_hfunc( xp , likeparams )
% Measurement function for the Acoustic measurement model
%
% Inputs:
% xp: state value where measurement function is evaluated
%  
% likeparams = struct('sensorsPos',sensorsPos,... %physical positions of the sensors
%    'Amp',Amp,... % Amplitude at source
%    'd0',d0,...  % distance threshold
%    'invPow',invPow,... % inverse Power (assumed 1 in this function)
%    'simAreaSize',simAreaSize,...  % size of the surveillance area
%    'nTarget',nTarget,... % number of Targets
%    'nSensor',nSensor); % number of sensors
%
%  Calculations for the acoustic sensor model 
%
%  r = sqrt[(x1-s1)^2 + (x2-s2)^2]
%  for state position (x1,x2) and sensor position (s1,s2)
%
%  h = sum (Amp/(r^invPow+d0))
%  for constants Amp,d0, and invPow

[dim,nParticles] = size(xp);

nSensor = likeparams.nSensor;
nTarget = likeparams.nTarget;
sensorsPos = likeparams.sensorsPos;

y = zeros(nSensor,nParticles);

xx = xp(1:4:nTarget*4,:);
xy = xp(2:4:nTarget*4,:);

x = [xx;xy];

if nParticles > 1
    v = bsxfun(@minus,sensorsPos,permute(x,[1 3 2]));
    v = v.^2;

    v = v(1:nTarget,:,:)+v(nTarget+1:2*nTarget,:,:);
    v = sqrt(v);

    v = likeparams.Amp./ (v.^likeparams.invPow+likeparams.d0);
    v = sum(v,1);

    y = squeeze(permute(v,[2 1 3]));
   
else
    v = bsxfun(@minus,sensorsPos,x);
    v = v.^2;
    
    v = v(1:nTarget,:,:)+v(nTarget+1:2*nTarget,:,:);
    v = sqrt(v);

    v = likeparams.Amp./ (v.^likeparams.invPow+likeparams.d0);

    v = sum(v,1);    
    y = v';
end

end

    


