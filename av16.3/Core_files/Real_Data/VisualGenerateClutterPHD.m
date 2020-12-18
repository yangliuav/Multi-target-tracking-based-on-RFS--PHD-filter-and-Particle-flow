function x = VisualGenerateClutterPHD(setup)

ps = setup.Ac;
x = zeros(setup.clutter,ps.T);
clutter = setup.clutter;

simAreaSize = ps.likeparams.simAreaSize;

for tt = 1:ps.setup.T
    for t = 1:clutter
        x(1+(t-1)*4:4*t,tt) = [simAreaSize*rand,simAreaSize*rand,0,0];
    end
end


end

