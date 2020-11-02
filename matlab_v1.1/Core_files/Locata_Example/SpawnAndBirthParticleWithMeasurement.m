function [vgset,clutter] = SpawnAndBirthParticleWithMeasurement(setup,vgset,z,H)
numParticle =  size(vgset,2);
sigma0 = setup.Ac.initparams.sigma0;
area   = setup.Ac.initparams.survRegion;
dim = 4;
H = setup.inp.H;
H =  ( H - min(min(H)))/(max(max(H)) - min(min(H)));
Cz =  zeros(1,size(z,2));
clutter = 0.0035;
for i = 1:size(z,2)
    for j = 1:size(vgset,2)
        switch setup.Ac.example_name
            case 'Acoustic'
                vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
            case 'Septier16'       
                [x,y] = generateSeptier16TrackMeasurements(setup);
            case 'Visual'
                vgset(j).llh(:,i) =  VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
            case 'Locata'
                vgset(j).llh(:,i) = VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                if (size(z,2) < 2)
                    vgset(j).PD = (interp2(H,vgset(j).xp(2),vgset(j).xp(1)))*vgset(j).llh(:,i);
                    clutter = 0.0035;
                   % vgset(j).w = vgset(j).w*1.05;
                end
                if size(z,2) == 2
                    vgset(j).PD = (interp2(H,vgset(j).xp(2),vgset(j).xp(1)));
                    clutter = 0.0035;
                end
                if size(z,2) > 2
                    clutter = 0.035*(size(z,2)- 2);
                end
                if isnan(vgset(j).llh(:,i) ) 
                    vgset(j).llh(:,i) =0;
                end
        end

        if(vgset(j).llh(:,i)>1)
            vgset(j).llh(:,i) =1;
        end
        Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w;
    end   
end


for j = 1:size(z,2)
    for i = (numParticle+1):(numParticle+fix(setup.nParticle))
        x = [z(1:2,j);0;0] + sigma0.*[rand(1)-0.5;rand(1)-0.5;rand(1)*0.1;rand(1)*0.1];
        vgset(i).xp = x;
        vgset(i).PP = zeros(4,4);
        vgset(i).PU = blkdiag(0.1,0.1,0.01,0.01);%(10,10,1,1);
        vgset(i).M  = x;
        vgset(i).xp_m = x;
        vgset(i).logW = 0;
        vgset(i).w  = 0.5*(1-Cz(:,j))/(setup.nParticle*size(z,2)); 
        vgset(i).PD = 1; 
        if isnan(vgset(i).w ) 
            vgset(i).w =0;
        end
    end
    numParticle = numParticle+fix(setup.nParticle);
end

end