function dH_dx = Acoustic_dH_dx(xp, likeparams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hessian of noiseless measurement function for the acoustic tracking model
%
% Inputs:
% xp: a state dimension vector
% likeparams: a structure containg the measurement model parameter values.
%
% Output:
% dH_dx: a dim_state x dim_sensor x dim_state matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dim,N] = size(xp);

if N~=1 || dim~=16
    error('This function only supports a single state of dimension = 16');
end

xx = xp(1:4:likeparams.nTarget*4,:);
yy = xp(2:4:likeparams.nTarget*4,:);
x = [xx;yy];

mv = bsxfun(@minus,x,likeparams.sensorsPos);
v = mv.^2;

r(1:likeparams.nTarget,:) = v(1:likeparams.nTarget,:)+v(likeparams.nTarget+1:2*likeparams.nTarget,:);
r = sqrt(r);

xr = mv(1:likeparams.nTarget,:);  %x1-s1_x,x5-s1_x,x9-s1_x,x13-s1_x,...,x1-s25_x,x5-s25_x,....
yr = mv(likeparams.nTarget+1:2*likeparams.nTarget,:);  %x2-s1_y,x6-s1_y,x10-s1_y,x14-s1_y,...,x2-s25_y,x6-s25_y,....

r_2(1:likeparams.nTarget,:) = v(1:likeparams.nTarget,:)+v(likeparams.nTarget+1:2*likeparams.nTarget,:);
rd0 = r+likeparams.d0;
rd0_3 = rd0.^3;    
r_3 = r.^3;

tempxx = -likeparams.Amp*(rd0.*r_2 - xr.^2.* (3*r+likeparams.d0) )./(rd0_3.*r_3);
tempxy = -likeparams.Amp*xr.* yr.* (3*r+likeparams.d0)./(rd0_3.*r_3);
tempyy = -likeparams.Amp*(rd0.*r_2 - yr.^2.* (3*r+likeparams.d0) )./(rd0_3.*r_3);

dH_dx = zeros(likeparams.nSensor,dim,dim);
dH_dx(:,1,1) = tempxx(1,:)';
dH_dx(:,2,1) = tempxy(1,:)';

dH_dx(:,1,2) = tempxy(1,:)';
dH_dx(:,2,2) = tempyy(1,:)';

dH_dx(:,5,5) = tempxx(2,:)';
dH_dx(:,6,5) = tempxy(2,:)';

dH_dx(:,5,6) = tempxy(2,:)';
dH_dx(:,6,6) = tempyy(2,:)';

dH_dx(:,9,9) = tempxx(3,:)';
dH_dx(:,10,9) = tempxy(3,:)';

dH_dx(:,9,10) = tempxy(3,:)';
dH_dx(:,10,10) = tempyy(3,:)';

dH_dx(:,13,13) = tempxx(4,:)';
dH_dx(:,14,13) = tempxy(4,:)';

dH_dx(:,13,14) = tempxy(4,:)';
dH_dx(:,14,14) = tempyy(4,:)';   

dH_dx = permute(dH_dx,[2 1 3]);