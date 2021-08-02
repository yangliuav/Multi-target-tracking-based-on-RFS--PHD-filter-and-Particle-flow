function [vgset] = SpawnAndBirthParticle_v1(setup,vgset)
numParticle =  size(vgset,2);
sigma0 = setup.Example.initparams.sigma0;
area   = setup.Example.initparams.survRegion;
dim = 4;
m0 = [area(3),area(4),sigma0(3),sigma0(4)]';
for i = (numParticle+1):(numParticle+setup.nParticle)
    vgset(i).xp = m0.*rand(4,1);
    vgset(i).PP = zeros(4,4);
    vgset(i).PU = blkdiag(100,100,1,1);
    vgset(i).M  = vgset(i).xp;
    vgset(i).xp_m = vgset(i).xp;
    vgset(i).logW = 0;
    vgset(i).w  = 1/50;
    vgset(i).PD = 1;
end

end