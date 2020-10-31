function [slope_real, log_jacobian_det] = NPF_homotopy_PHDV2(z,vgset,setup,lambda,step_size,Cz)   
N = size(vgset(1,:),2);
dim = size(vgset(1,1).xp,1);
[zdim,znum] = size(z);
log_jacobian_det = ones(1,N);
slope_real = zeros(dim/2,N);
vgsetold = vgset;        

d2 = zeros(N,znum);
H = setup.inp.H;
%h1 = setup.inp.h1;
%h2 = setup.inp.h2;
%r= setup.inp.clutter
r=  setup.clutter;
for ii = 1:N
%    h = vgset(ii).llh; 
    x = vgset(ii).xp(1:2,:);
    for j = 1:znum
        d = x - z(:,j);
        vgset(ii).h(j) = interp2(H,vgset(ii).xp(2),vgset(ii).xp(1))*VisualGaussian_llh_PHD(vgset(ii).xp,z(:,j),setup.Ac.likeparams);
        
        %d2(ii,j) = 2^0.5*(d(1)^2+d(2)^2)/50;
        %vgset(ii).h(j) = besselk(0,d2(ii,j))/pi;
    end
end
Cz = zeros(1,znum);
for j = 1:znum
    for ii = 1:N
       h = vgset(ii).h(j)*vgset(ii).w;
       if isnan(h)
           h = 0;
       end
       Cz(:,j) = Cz(:,j)+h; 
    end
end
for ii = 1:N
    A = zeros(2,2);
    a = zeros(2,2);
    B = zeros(2,1);
    b = zeros(2,1);
    x = vgset(ii).xp(1:2,:);
%    h1 = 2^1.5/pi*besselk(1,d2(ii,j))*(x - z(:,j));
%    h2 = 2^0.5/pi*(besselk(-2,d2(ii,j))+2*besselk(0,d2(ii,j))+besselk(2,d2(ii,j)))*(x - z(:,j))*(x - z(:,j))'-2^1.5/pi*besselk(1,d2(ii,j))*[1,0;0,1];

    for j = 1:znum   
        h1 = 2^1.5/pi*besselk(1,d2(ii,j))*(x - z(:,j));
        h2 = 2^0.5/pi*(besselk(-2,d2(ii,j))+2*besselk(0,d2(ii,j))+besselk(2,d2(ii,j)))*(x - z(:,j))*(x - z(:,j))'-2^1.5/pi*besselk(1,d2(ii,j))*[1,0;0,1];
        A = A+setup.detect*lambda*h2/(0.008+Cz(:,j));
        B = B+setup.detect*h1/(0.008+Cz(:,j)); 
    end  
%     for j = 1:znum
%         % original code
%         h1 = 2^1.5/pi*besselk(1,d2(ii,j))*(x - z(:,j));
%         h2 = 2^0.5/pi*(besselk(-2,d2(ii,j))+2*besselk(0,d2(ii,j))+besselk(2,d2(ii,j)))*(x - z(:,j))*(x - z(:,j))'-2^1.5/pi*besselk(1,d2(ii,j))*[1,0;0,1];
%         a = [interp2(h2(:,:,1,1),vgset(ii).xp(2),vgset(ii).xp(1)),interp2(h2(:,:,1,2),vgset(ii).xp(2),vgset(ii).xp(1));interp2(h2(:,:,2,1),vgset(ii).xp(2),vgset(ii).xp(1)),interp2(h2(:,:,2,2),vgset(ii).xp(2),vgset(ii).xp(1))];
%         b = [interp2(h1(:,:,1),vgset(ii).xp(2),vgset(ii).xp(1));interp2(h2(:,:,2),vgset(ii).xp(2),vgset(ii).xp(1))] + (x - z(:,j))*VisualGaussian_llh_PHD(vgset(ii).xp,z(:,j),setup.Ac.likeparams);
%         A = A+ vgset(ii).PD*lambda*a/(r+Cz(:,j));
%         B = B+ vgset(ii).PD*b/(r+Cz(:,j));
%     end

    slope_real(:,ii) = -1*B;%-1*(A+vgset(ii).PP(1:2,1:2))^-1*B;
end




end