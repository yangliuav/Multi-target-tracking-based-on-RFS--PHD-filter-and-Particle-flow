function  vgset = compare_particle(Sensor,numParticle)
% This function implements proposed particles comparision in IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
% Inputs:
% t: time stamp
% setup: algorithm setup
% iy: measurement in i-th sensor
% Sensor: particles set in i-th sensor
% 
% Outputs:

%%

vgset = Sensor.vgset;
End = size(vgset,2);

XP = [];
for i = 1:numParticle
    XP = [XP;vgset(i).xp(1:2)'];
end

for i = numParticle:End
    xp = vgset(i).xp(1:2)';
    index = find(XP == xp);
    index = index(1:size(index)/2);
    n = size(index)
    for ij = 1:n
        vgset(index(ij)).w = vgset(index(ij)).w * vgset(i).w;
    end
%     if size(index)
%         for j = index
%             vgset(j).w = vgset(j).w * vgset(i).w;
%         end
%     end
    vgset(i).w = 0;
end


end

