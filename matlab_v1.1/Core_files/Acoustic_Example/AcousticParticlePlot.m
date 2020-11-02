function AcousticParticlePlot(vg,ps,slope,tt,xlab)
% Plotting function for the Acoustic sensor example
%% Input:
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

xmin = ps.likeparams.trackBounds(1);
xmax = ps.likeparams.trackBounds(3);
ymin = ps.likeparams.trackBounds(2);
ymax = ps.likeparams.trackBounds(4);

figure(1);movegui('northwest');
numTargets = ps.initparams.nTarget;
dimState_per_target = ps.setup.dimState_per_target;

if strcmp(xlab,'before propagation')
    x = ps.x(:,max(tt-1,1));
else
    x = ps.x(:,tt);
end
    
hold off;

color_cell = {'b','r','g','k'};

for ii = 1:numTargets
    xind = (ii-1)*dimState_per_target+1;
    yind = (ii-1)*dimState_per_target+2;
    plot(vg.xp_m(xind),vg.xp_m(yind),'p','MarkerEdgeColor',color_cell{ii},'markersize',25,'markerfacecolor',color_cell{ii});...'gp','markersize',10,'markerfacecolor','g');
            hold on;
end

for ii = 1:numTargets
    xind = (ii-1)*dimState_per_target+1;
    yind = (ii-1)*dimState_per_target+2;
    plot(x(xind),x(yind),'d','markeredgecolor','m','markersize',18,'markerfacecolor','m');
end

for ii = 1:numTargets

    xind = (ii-1)*dimState_per_target+1;
    yind = (ii-1)*dimState_per_target+2;
    
    plot(vg.xp_m(xind),vg.xp_m(yind),'p','MarkerEdgeColor',color_cell{ii},'markersize',25,'markerfacecolor',color_cell{ii});...'gp','markersize',10,'markerfacecolor','g');
    hold on;
    plot(x(xind),x(yind),'d','MarkerEdgeColor',color_cell{ii},'markersize',18,'markerfacecolor',color_cell{ii});
        
    nParticle_plot = 500;
    if size(vg.xp,2)>nParticle_plot
        particle_ind = round(linspace(1,size(vg.xp,2),nParticle_plot)); %randperm(size(vg.xp,2),nParticle_plot);
    else
        particle_ind = 1:size(vg.xp,2);
    end
    
    scatter(vg.xp(xind,particle_ind),vg.xp(yind,particle_ind),300,color_cell{ii});
    grid on;
    quiver(vg.xp(xind,particle_ind),vg.xp(yind,particle_ind),4*slope(xind,particle_ind),4*slope(yind,particle_ind),'r');
end

for ii = 1:numTargets
    xind = (ii-1)*dimState_per_target+1;
    yind = (ii-1)*dimState_per_target+2;
    
%     hold on;
    plot(vg.xp_m(xind),vg.xp_m(yind),'p','MarkerEdgeColor',color_cell{ii},'markersize',25,'markerfacecolor',color_cell{ii});...'gp','markersize',10,'markerfacecolor','g');
    plot(x(xind),x(yind),'d','markeredgecolor','m','markersize',18,'markerfacecolor','m');
end

h_leg = legend('Target 1 PF estimate',...
    'Target 2 PF estimate',...
    'Target 3 PF estimate',...
    'Target 4 PF estimate','Targets true pos.');
set(h_leg,'FontSize',ps.setup.fontSize,'Location','southeast');

if exist('xmin')
    axis([xmin xmax ymin ymax]);
else
    axis(ps.likeparams.trackBounds([1,3,2,4]));
end

title(['Time step: ',num2str(tt),', ',xlab],'FontSize',ps.setup.fontSize);
xlabel(['X (m)'],'FontSize',ps.setup.fontSize);
ylabel('Y (m)','FontSize',ps.setup.fontSize);
set(gcf,'color','w');
set(gca,'FontSize',ps.setup.fontSize);
set(gcf, 'Position', [100, 100, 1000, 900]);
hold off
print([int2str(tt),xlab(25:end),'BarPlot.png'],'-dpng')
end

% Helper functions for plotting the covariance matrix ellipses

function sph2d=sphere2d(x,P)
[vv,dd]=eig(P);
[xx,yy]=ellipse(0,0,sqrt(dd(1,1)),sqrt(dd(2,2)),100);
sph2d=vv*[xx;yy]+x(1:2)*ones(1,size(xx,2));

end

function [x,y]=ellipse(x0,y0,rx,ry,N)

count=0;
for phi=0:pi/N:2*pi
    count=count+1;
    x(count)=rx*cos(phi)+x0;
    y(count)=ry*sin(phi)+y0;
end

end
