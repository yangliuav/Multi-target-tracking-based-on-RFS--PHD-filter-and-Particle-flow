function [vgset,setup] = posteriorPHD(vgset,setup,z_current,H,clutter)
    z = cell2mat(z_current);
    xz = 0;
    Cz =  zeros(1,size(z,2));
    for i = 1:size(z,2)
        for j = 1:size(vgset,2)
            switch setup.Ac.example_name
                case 'Acoustic'
                    vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                case 'Septier16'       
                    [x,y] = generateSeptier16TrackMeasurements(setup);
                case 'Visual'
                    vgset(j).llh(:,i) =  VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                case 'Real_Data'
                    vgset(j).llh(:,i) =  VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                case 'Locata'
                    vgset(j).llh(:,i) = interp2(H,vgset(j).xp(2),vgset(j).xp(1))*VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
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
    vgsetold = vgset;
    if size(z,2) ~= 0
        switch setup.pf_type
            case 'ZPF'
                vgset = particleFlowPHD(vgset,setup,z,Cz);
            case {'NPF','NPFS'}
                vgset = particleFlowPHD(vgset,setup,z,Cz);
            case 'IPF'
                vgset = particleFlowPHD(vgset,setup,z,Cz);
            case 'SMC'
        end   
    end
    if isnan(vgset(1).xp(1)) == 1
        vgset = vgsetold;
    end
    if strcmpi(setup.pf_type,'SMC')
        Cz =  zeros(1,size(z,2));
        for i = 1:size(z,2)
            for j = 1:size(vgset,2)
                switch setup.Ac.example_name
                    case 'Acoustic'
                        vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                    case 'Septier16'       
                        [x,y] = generateSeptier16TrackMeasurements(setup);
                    case 'Visual'
                        vgset(j).llh(:,i) =  VisualLaplace_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
                    case 'Locata'
                        vgset(j).llh(:,i) = interp2(H,vgset(j).xp(2),vgset(j).xp(1))*VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),setup.Ac.likeparams);
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
    end

    
    for j = 1:size(vgset,2)
        xz = 0;
        for i = 1:size(z,2)
            wlik = vgset(j).llh(:,i)/(clutter+Cz(:,i));
            xz = xz+wlik;
            vgset(j).wlik(i) = wlik;
        end
        
         vgset(j).w =(1-vgset(j).PD)*vgset(j).w +  vgset(j).w*xz*vgset(j).PD;
        if isnan(vgset(j).w)
            vgset(j) = vgset(1);
        end
        %%
        % 
        % $$e^{\pi i} + 1 = 0$$
        % 
    end
    
     
end