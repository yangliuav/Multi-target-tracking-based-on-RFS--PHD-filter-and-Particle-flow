n_start = 1;
n_end = 1;
sumw = ones(1,40);
for i =1:40
    n = tracking_output.SMC_PHD.Nvgset(i);
    n_end = n_start-1+n;
    sumw(:,i) = sum(tracking_output.ZPFSMC.vgsetw(n_start:n_end)); 
    n_start = n_end +1;
end

p=particle_state(:,inx);
       for i = 1: size(p,2)
            x_pos_i =p(1,i);
            y_pos_i = p(2,i);
            plot(x_pos_i(1),y_pos_i(1),'o','Color','r','LineWidth',3,'MarkerSize',10);  %# Plot each column with a
       end
  
h = vgset(i).llh; 
x = vgset(i).xp(1:2,:);
A = 0;
B = 0;
C = 0;
C1 =0;
C2 = 0;
for j = 1:znum
    A = A + 2*(x(1:2,:)-z(:,j))*h(:,j)*(0.008+ Cz(:,j));
    B1 = 0;
    for i =1:N
        B1 = B1 + 2*(x(1:2,:)-z(:,j))*vgset(i).llh(:,j)*vgset(i).w + vgset(i).llh(:,j);
    end
    B = B + B1*h(:,j);
    C1 = C1 + h(:,j)/(0.008+ Cz(:,j));
    C2 = C2 + (0.008+ Cz(:,j))^2;
end
C = (C1)*C2;

       
