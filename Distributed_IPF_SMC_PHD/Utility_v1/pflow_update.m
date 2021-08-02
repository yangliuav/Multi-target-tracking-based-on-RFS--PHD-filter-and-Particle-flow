function [vgset,args] = pflow_update(sensor,args,z_current,clutter,surv_particle_num,Cz,nSi)
%PFLOW_UPDATE Summary of this function goes here
%   Detailed explanation goes here

%%
vgset = sensor.vgset
z = cell2mat(z_current);

%% step 5: IPF on survival particles
vgsetold = vgset;
if size(z,2) ~= 0
    sensor.vgset = vgset;
    vgset = particleFlowPHD(sensor,args,z,Cz,surv_particle_num,nSi); % particles moved by particle flow
end
if isnan(vgset(1).xp(1)) == 1
    vgset = vgsetold;
end

%% Update weight
temp_a = [];
for j = 1:surv_particle_num%size(vgset,2)
    xz = 0;
    for i = 1:size(z,2)
        wlik = vgset(j).llh(:,i)/(clutter+Cz(:,i));
        xz = xz+wlik;
        temp_a = [temp_a xz];
        vgset(j).wlik(i) = wlik;
    end        
    vgset(j).w =(1-vgset(j).PD)*vgset(j).w +  vgset(j).w*xz*vgset(j).PD;
    if isnan(vgset(j).w)
        vgset(j) = vgset(1);
    end
end

end

