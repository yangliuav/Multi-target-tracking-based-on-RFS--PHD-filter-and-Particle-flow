function vgset = post_p_weight_update(sensor,args,z_current)

vgset = sensor.vgset
z = cell2mat(z_current);
xz = 0;
Cz =  zeros(1,size(z,2)); 

% calculate likelihood of each particles on measurements
for i = 1:size(z,2)
    for j = 1:size(vgset,2)
        vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z(:,i),args.Example.likeparams);
        if(vgset(j).llh(:,i)>1)
            vgset(j).llh(:,i) =1;
        end
        Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w; % likelihood * weights? update period for sum result
    end
end

% Update weight
temp_a = []
for j = 1:size(vgset,2)
    xz = 0;
    for i = 1:size(z,2)
        wlik = vgset(j).llh(:,i)/(Cz(:,i));
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

