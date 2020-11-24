function [slope_real, log_jacobian_det] = NPF_homotopy_PHD(z,vgset,setup,lambda,step_size,Cz)   
        
N = size(vgset(1,:),2);
dim = size(vgset(1,1).xp,1);
[zdim,znum] = size(z);
log_jacobian_det = ones(1,N);
slope_real = zeros(dim/2,N);
H = [1,0;0,1];
% for i = 1:N
%     
%     Bz = 0;
%     h = vgset(i).llh; 
%     x = vgset(i).xp(1:2,:);
%     G = [vgset(i).w*(x(1) - vgset(i).xp_m(1))^2+vgset(i).w, vgset(i).w*(x(1) - vgset(i).xp_m(1))*(x(2) - vgset(i).xp_m(2));vgset(i).w*(x(1) - vgset(i).xp_m(1))*(x(2) - vgset(i).xp_m(2)), vgset(i).w*(x(2) - vgset(i).xp_m(2))^2+vgset(i).w];
%     G = [vgset(i).w*(x(1) - vgset(i).xp_m(1))^2+vgset(i).w, vgset(i).w*(x(2) - vgset(i).xp_m(2))^2+vgset(i).w];
% 
%     for j = 1:znum
%         B(:,j) = h(j)/sum(h)*(x(1:2,:)-z(:,j))*(log(h(j))-h(j)*log(h(j))+1)/(0.008+ Cz(:,j));
%         if isnan(B(:,j))
%             B(:,j) = [0,0]';
%         end
%         Bz = Bz + 2*B(:,j);
%     end
%     slope_real(:,i) = [1/setup.PHD.P_detect*Bz]*10^(-2);%H/G
% end
% k = 0%0.008;
vgsetold = vgset;
for ii = 1:N
    h = vgset(ii).llh; 
    x = vgset(ii).xp(1:2,:);
    A = 0;
    B = 0;
    C = 0;
    C1 =0;
    C2 = 0;
    C3 = 0;
    for j = 1:znum
        A = A + 2*(x(1:2,:)-z(:,j))*h(:,j)*(0.008+ Cz(:,j));
        B1 = 0;
        for i =1:N
            B1 = B1 + 2*(x(1:2,:)-z(:,j))*vgset(i).llh(:,j)*vgset(i).w + 2*(x(1:2,:)-vgsetold(ii).xp(1:2,:))*vgset(i).w*vgset(i).llh(:,j);
        end
        B = B + B1*h(:,j);
        C1 = C1 + h(:,j)/(0.008+ Cz(:,j));
        C2 = C2 + (0.008+ Cz(:,j))^2;
        C3 = C3 + h(:,j)*(0.008+ Cz(:,j));
    end
    C = (C1*1.1)*C2;
    slope_real(:,ii)  = -(A-B)/C3;
end

end