function [vgset] = SpawnAndBirthParticle(args,ps,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function controls particles'spawn and birth
%
% Input:
% args: setup
% vgset: previous particles set
%
% Output:
% vgset: updated particles set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vgset = ps.vgset;
numParticle =  size(vgset,2);
sigma0 = args.Example.initparams.sigma0;
area   = args.Example.initparams.survRegion;
dim = 4; % might not used
% m0 = [area(3),area(4),sigma0(3),sigma0(4)]';

z = cell2mat(z);
gen_area = max(area(3),area(4))*0.5;
m0 = [gen_area, gen_area, sigma0(3),sigma0(4)]';

for i = 1:size(z,2)
    zr = z(:,i);
    for j = 1:args.nParticle
        index = numParticle + ((i-1)*args.nParticle) + j;
        xp = [zr(1)-(0.5*gen_area);zr(2)-(0.5*gen_area);0;0] + m0.*rand(4,1); % particle state
        vgset(index).xp = xp;
        vgset(index).PP = zeros(4,4);               % particle prediction
        vgset(index).PU = blkdiag(100,100,1,1);     % particle update
        vgset(index).M  = vgset(i).xp;
        vgset(index).xp_m = vgset(i).xp;
        vgset(index).logW = 0;
        vgset(index).w  = 1/50;
        vgset(index).PD = 1;
        vgset(index).B = 0;
    end
end

% for i = (numParticle+1):(numParticle+args.nParticle)
%     vgset(i).xp = m0.*rand(4,1);            % particle position
%     vgset(i).PP = zeros(4,4);               % particle prediction
%     vgset(i).PU = blkdiag(100,100,1,1);     % particle update
%     vgset(i).M  = vgset(i).xp;
%     vgset(i).xp_m = vgset(i).xp;
%     vgset(i).logW = 0;
%     vgset(i).w  = 1/50;
%     vgset(i).PD = 1;
%     vgset(i).B = 0;
% end


end