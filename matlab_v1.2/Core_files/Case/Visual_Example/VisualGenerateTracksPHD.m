function x = VisualGenerateTracksPHD(setup)

ps = setup.Ac;
x = zeros(ps.dimState_all* ps.initparams.nTarget,ps.T);

nTarget = ps.initparams.nTarget;
simAreaSize = ps.likeparams.simAreaSize;

outofbounds = 1;

nFailedTracks = 0;
% Repeatedly generate tracks until no target leaves the surveillance region
while outofbounds
    outofbounds = 0;
    x(:,1) = VisualPropagate(ps.initparams.x0,ps.propparams_real);
    for tt = 2:ps.setup.T
        x(:,tt) = VisualPropagate(x(:,tt-1),ps.propparams_real);
    end

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



end

