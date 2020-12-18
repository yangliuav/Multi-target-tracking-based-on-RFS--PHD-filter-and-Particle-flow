function x = GenerateTracks(ps)
% 
% Generates target trajectories for the 4-target acoustic sensor example
%
% Input: parameter structure, including initial states, propagation
% parameters and trajectory constraints
%
% Output: the state trajectories (no_targets*4, T)
%

x = zeros(ps.setup.dimState_all,ps.setup.T);

nTarget = ps.initparams.nTarget;
simAreaSize = ps.likeparams.simAreaSize;

outofbounds = 1;

nFailedTracks = 0;
% Repeatedly generate tracks until no target leaves the surveillance region
while outofbounds
    outofbounds = 0;
    x(:,1) = AcousticPropagate(ps.initparams.x0,ps.propparams_real);
    for tt = 2:ps.setup.T
        x(:,tt) = AcousticPropagate(x(:,tt-1),ps.propparams_real);
    end;
    xx = x(1:4:4*nTarget,:);
    yy = x(2:4:4*nTarget,:);
    
    if sum(any(xx<0.05*simAreaSize))||sum(any(xx>0.95*simAreaSize))
        outofbounds = 1;
    end
    if sum(any(yy<0.05*simAreaSize))||sum(any(yy>0.95*simAreaSize))
        outofbounds = 1;
    end
    nFailedTracks = nFailedTracks + 1;
end

if ps.setup.doplot && (ps.setup.nTrack == 1)
    cmap = hsv(nTarget);  %# Creates a 6-by-3 set of colors from the HSV colormap
    figure(20);clf;hold on;
    set(gcf, 'Position', [100, 100, 1000, 900]);
        load 'sensorsXY';
    fontsize = 24;
    simAreaSize=40; %size of the area
    switch ps.setup.nTarget
        case {8,12,16}
            simAreaSize = 100;
    end
    sensorsPos = simAreaSize/40*sensorsXY; %physical positions of the sensors
    h=scatter(sensorsPos(:,1),sensorsPos(:,2),'bo','filled');
    set(h, 'SizeData', 125)
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);
        plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:),'LineWidth',2,'MarkerSize',7);  %# Plot each column with a
    end
                
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);

        plot(x_pos_i(1),y_pos_i(1),'xk','LineWidth',3,'MarkerSize',30);  %# Plot each column with a
    end
        
    h_leg=legend('Sensor','Target 1','Target 2','Target 3','Target 4','starting position');
    set(h_leg,'FontSize',fontsize,'Location','southeast');

    grid on;
%     axis equal
    axis(ps.likeparams.survRegion([1,3,2,4]))
    set(gca,'xtick',0:10:40,'ytick',0:10:40,'FontSize',fontsize);
    set(gcf,'color','w');
    xlabel('X (m)','FontSize',fontsize);
    ylabel('Y (m)','FontSize',fontsize);
%     export_fig('setup.pdf');
end

end

