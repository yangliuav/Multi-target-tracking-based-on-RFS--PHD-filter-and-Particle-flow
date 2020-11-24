function Septier16_ParticlePlot(vg,ps,slope,tt,xlab)
%% Plotting function for 'Septier16' example
%
% Input:
% vg: a struct that contains the filter output
% ps: structure with filter and simulation parameters
% slope: a matrix of size dim x nParticle that contains the slopes (if
% any) of each particle during the flow.
% tt: the time step index.
% xlab: a string describing the figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5
    xlab = [];
end

figure(1);movegui('northwest');

if strcmp(xlab,'before propagation')
    x = ps.x(:,max(tt-1,1));
else
    x = ps.x(:,tt);
end
    
hold off;
figure(1);imagesc(x);
title(['Time step: ', num2str(tt), ': true state']);colorbar;
% xlabel('Particle index');
ylabel('State dimension');
colorbar;movegui('northwest');
figure(4);imagesc(reshape(x,sqrt(ps.setup.dimState_all),sqrt(ps.setup.dimState_all)));
title(['Time step: ', num2str(tt), ': true state']);colorbar;
xlabel('x');
ylabel('y');
colorbar;movegui('southwest');
figure(2);imagesc(vg.xp);
title(['Time step: ', num2str(tt), ': particles, ',xlab]);colorbar;
xlabel('Particle index');
ylabel('State dimension');
movegui('north');
figure(5);imagesc(reshape(vg.xp_m,sqrt(ps.setup.dimState_all),sqrt(ps.setup.dimState_all)));
title(['Time step: ', num2str(tt), ': estimated state, ',xlab]);colorbar;
xlabel('x');
ylabel('y');
movegui('south');
figure(3);imagesc(slope);
xlabel('Particle index');
ylabel('State dimension');
title(['Time step: ', num2str(tt), ': slopes, ',xlab]);
colorbar;movegui('northeast');

end