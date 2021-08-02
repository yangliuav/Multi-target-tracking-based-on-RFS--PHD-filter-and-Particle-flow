function  [vgset,numParticle,Cz,nSi] = birth_model(args,z,clutter,sensor)
% This function implements proposed birth model in IPF-SMC-PHD algorithm by Dr. Yang Liu
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
vgset = sensor.vgset;
numParticle = size(vgset,2);
z = cell2mat(z);
sigma0 = args.Example.initparams.sigma0;
area   = args.Example.initparams.survRegion;
gen_area = max(area(3),area(4))*0.2;
m0 = [gen_area, gen_area, sigma0(3),sigma0(4)]';
%% calculate likelihood of each survival particles on measurements

xz = 0;
Cz =  zeros(1,size(z,2)); 

% calculate likelihood of each particles on measurements
for i = 1:size(z,2)
    for j = 1:size(vgset,2)
        vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z(:,i),args.Example.likeparams);
        if(vgset(j).llh(:,i)>1)
                vgset(j).llh(:,i) =1;
        end
        Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w; % PD.(search for update 0.98) likelihood * weights? update period for sum result
    end
end

%% Eq. 57
% birth_intensity * max(0,1- prob of r-th measurement by target state m_k^i)
nCz = zeros(1,6);
nSi = zeros(1,6);
for i = 1:size(z,2)
    zr = z(:,i);
    for j = 1:args.nParticle
        index = numParticle + ((i-1)*args.nParticle) + j;
        xp = [zr(1)-(0.5*gen_area);zr(2)-(0.5*gen_area);0;0] + m0.*rand(4,1); % particle state
        vgset(index).xp = xp;
        vgset(index).PP = zeros(4,4); % 
        vgset(index).PU = blkdiag(100,100,1,1);
        vgset(index).M = vgset(index).xp;
        vgset(index).xp_m = vgset(index).xp;
        vgset(index).logW = 0;
        Si = (max(0,1-Cz(i))*0.5)/mvnpdf(xp(1:2),zr);%max(normpdf(xp(1:2),zr)); % birth_intensity = 0.5 ; particle_pos, measurement_pos, measurement_noise
        w = Si/args.nParticle;
        vgset(index).w = w; % weights here different
        vgset(index).PD = 1;
        vgset(index).B = 0;
        vgset(index).llh = Gaussian_llh_PHD(xp,zr,args.Example.likeparams);
        nCz(i) = nCz(i) + vgset(index).llh * vgset(index).w * vgset(index).PD;
        nSi(i) = nSi(i) + Si;
    end
end

nCz = nCz + Cz;
%% Eq.58
for i = 1:size(z,2)
    for j = 1:args.nParticle
        index = numParticle + ((i-1)*args.nParticle) + j;
        vgset(index).w = (vgset(index).llh * vgset(index).w)/(clutter + 0.99*nCz(i)); % Pd = 0.99
        vgset(index).wlik = vgset(index).llh/(clutter + 1*nCz(i)); % nCz + update
    end   
end


end

