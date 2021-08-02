function [vgset,args,Cz] = posteriorPHD(sensor,args,z_current,clutter)
% This function implements proposed IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been modified by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% posterior PHD
%
% Input:
% args: setup
% vgset: particles set
% z_current: measurement
% clutter:
%
% Output:
% args: setup
% vgset: particles set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w; % PD.(search for update 0.98) likelihood * weights? update period for sum result
    end
end
     
vgsetold = vgset;
if size(z,2) ~= 0
    sensor.vgset = vgset;
    vgset = particleFlowPHD(sensor,args,z,Cz); % particles moved by particle flow
end
if isnan(vgset(1).xp(1)) == 1
    vgset = vgsetold;
end
    
%     Cz =  zeros(1,size(z,2)); % ??????
%     
%     for i = 1:size(z,2)
%         for j = 1:size(vgset,2)
%             vgset(j).llh(:,i) =  VisualGaussian_llh_PHD(vgset(j).xp,z(:,i),args.Example.likeparams);
%         end
%         if(vgset(j).llh(:,i)>1)
%                 vgset(j).llh(:,i) =1;
%         end
%         Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w; % likelihood * weights? update period for sum result
%     end
    
% Update weight
temp_a = [];
for j = 1:size(vgset,2)
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