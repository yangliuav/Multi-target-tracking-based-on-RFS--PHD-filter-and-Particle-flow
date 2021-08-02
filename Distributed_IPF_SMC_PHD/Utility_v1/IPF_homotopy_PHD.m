function [slope_real, log_jacobian_det, vgset] = IPF_homotopy_PHD(z,vgset,setup,lambda,step_size,Cz,surv_particle_num,nSi)
Bpre = [];
N = surv_particle_num;%size(vgset(1,:),2);
dim = size(vgset(1,1).xp,1);
[zdim,znum] = size(z);
log_jacobian_det = ones(1,N);
slope_real = zeros(dim/2,N);
H = [1,0;0,1];
%PD=0.008 % adjust as the setting

for ii = 1:N
    h = vgset(ii).llh; % likelihood
    x = vgset(ii).xp(1:2,:); % particle position
    d = repmat(x,1,size(h,2))-z; % distance
	C = 0;
	for j = 1:znum
		C = C + vgset(ii).llh(:,j);
	end 
	C = C/sum(0.0125+Cz+nSi);
    PD = vgset(ii).PD;
    Bpre(ii) = vgset(ii).B;
	vgset(ii).B= 2 *(PD*C/(1-PD+PD*C))*sum(h);
	slope_real(:,ii)  = sum( -(lambda*eye(dim/2)*(vgset(ii).B-Bpre(ii))-vgset(ii).PP(1:2,1:2)^-1)*vgset(ii).B*d.*h,2); % slope_real 是 f 吧？P
    
end
