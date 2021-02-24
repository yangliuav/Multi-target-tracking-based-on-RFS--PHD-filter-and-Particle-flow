function [slope_real, log_jacobian_det, B] = IPF_homotopy_PHD(z,vgset,setup,lambda,step_size,Cz, Bpre)   
% Bpre is previous B


N = size(vgset(1,:),2);
dim = size(vgset(1,1).xp,1);
[zdim,znum] = size(z);
log_jacobian_det = ones(1,N);
slope_real = zeros(dim/2,N);
H = [1,0;0,1];
PD=0.008 % adjust as the setting
for ii = 1:N
    h = vgset(ii).llh; 
    x = vgset(ii).xp(1:2,:);
	C = 0
	for j = 1:znum
		C = C + vgset(ii).llh(:,j)
	end 
	C = C/Cz
	B[ii]= 2*(PD*C/(1-PD+PD*C))*h
	slope_real(:,ii)  = -(lambda(B[ii]-Bpre[ii])-vgset(ii).P^-1)|*B[ii] % slope_real 是 f 吧？P
    
end
