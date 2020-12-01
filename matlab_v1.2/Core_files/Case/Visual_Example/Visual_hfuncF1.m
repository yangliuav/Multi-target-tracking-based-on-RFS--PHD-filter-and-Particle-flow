function y = Visual_hfuncF1( xp , likeparams )
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

y = xp(1:2,:);

end

    


