function x = VisualGenerateTracksPHD(args)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates Tracks
%
% Input:
% args: setup but only setup.Ac useful
%
% Output:
% x: a series state of targets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps = args.Example;
x = zeros(ps.dimState* ps.initparams.nTarget,ps.T);

nTarget = ps.initparams.nTarget;
simAreaSize = ps.likeparams.survRegion(3);

outofbounds = 1;

nFailedTracks = 0;
% Repeatedly generate tracks until no target leaves the surveillance region
while outofbounds
    outofbounds = 0;
    % using motion model to move targets
    x(:,1) = Propagate(ps.initparams.x0,ps.propparams_real);
    for tt = 2:ps.T
        x(:,tt) = Propagate(x(:,tt-1),ps.propparams_real);
    end

    xx = x(1:4:4*nTarget,:); % position x of each target
    yy = x(2:4:4*nTarget,:); % position y of each target
    
    % check out of bounds or not ([0.05,0.95])
    if sum(any(xx<0.05*simAreaSize))||sum(any(xx>0.95*simAreaSize))
        outofbounds = 1;
    end
    if sum(any(yy<0.05*simAreaSize))||sum(any(yy>0.95*simAreaSize))
        outofbounds = 1;
    end
    nFailedTracks = nFailedTracks + 1;
end



end

