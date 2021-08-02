function x = VisualGenerateClutterPHD(args)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates clutters
% The unwanted measurements are referred as clutter measurements
%
% Input:
% args: setup but only setup.Ac useful
%
% Output:
% x: a series state of unwanted measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps = args.Example;
x = zeros(args.clutter,ps.T);
clutter = args.clutter;

simAreaSize = ps.likeparams.survRegion(3);

for tt = 1:ps.T
    for t = 1:clutter
        x(1+(t-1)*4:4*t,tt) = [simAreaSize*rand,simAreaSize*rand,0,0];
    end
end


end

