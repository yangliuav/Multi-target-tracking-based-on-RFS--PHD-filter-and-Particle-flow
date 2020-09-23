function x = GenerateTracks_bounce(ps)
% 
% Generates target trajectories for the 4-target acoustic sensor example
%
% Input: parameter structure, including initial states, propagation
% parameters and trajectory constraints
%
% Output: the state trajectories (no_targets*4, T)
%

x = zeros(ps.dimState_all,ps.T);

nTarget = ps.initparams.nTarget;
simAreaSize = ps.likeparams.simAreaSize;

outofbounds = 1;
max_speed = 1;
pos_ix = unique([1:4:4*nTarget;2:4:4*nTarget]);
vel_ix = unique([3:4:4*nTarget;4:4:4*nTarget]);

nFailedTracks = 0;
% Repeatedly generate tracks until no target leaves the surveillance region
while outofbounds
    outofbounds = 0;
    x(:,1) = AcousticPropagate(ps.initparams.x0,ps.propparams_real);
    for tt = 2:ps.T
        x(:,tt) = AcousticPropagate(x(:,tt-1),ps.propparams_real);
                
        % find positions out of range
        ind_out_of_range = (x(pos_ix,tt)<0.05*simAreaSize);
        x(pos_ix(ind_out_of_range),tt) = 0.1*simAreaSize-x(pos_ix(ind_out_of_range),tt);
        x(pos_ix(ind_out_of_range)+2,tt) = -x(pos_ix(ind_out_of_range)+2,tt);
        
        ind_out_of_range = (x(pos_ix,tt)>0.95*simAreaSize);
        x(pos_ix(ind_out_of_range),tt) = 1.9*simAreaSize-x(pos_ix(ind_out_of_range),tt);
        x(pos_ix(ind_out_of_range)+2,tt) = -x(pos_ix(ind_out_of_range)+2,tt);
        
        ind_out_of_range = (x(vel_ix,tt)>max_speed);
        x(vel_ix(ind_out_of_range),tt) = 2*max_speed-x(vel_ix(ind_out_of_range),tt);
        
        ind_out_of_range = (x(vel_ix,tt)<-max_speed);
        x(vel_ix(ind_out_of_range),tt) = -2*max_speed-x(vel_ix(ind_out_of_range),tt);
    end
    xx = x(1:4:4*nTarget,:);
    yy = x(2:4:4*nTarget,:);
    
    if sum(any(xx<0.05*simAreaSize))||sum(any(xx>0.95*simAreaSize))
        outofbounds = 1;
    end
    if sum(any(yy<0.05*simAreaSize))||sum(any(yy>0.95*simAreaSize))
        outofbounds = 1;
    end
    
    % Do not allow large movements
    if nnz(abs(x(vel_ix,:)) > max_speed)
        outofbounds = 1;
    end
    
    nFailedTracks = nFailedTracks + 1;
end

if ps.doplot
    cmap = hsv(nTarget);  %# Creates a 6-by-3 set of colors from the HSV colormap
    figure(20);clf;hold on;
    for i = 1:nTarget
        x_pos_i = x((i-1)*4+1,:);
        y_pos_i = x((i-1)*4+2,:);
        plot(x_pos_i,y_pos_i,'-s','Color',cmap(i,:));  %# Plot each column with a
    end
end

end

