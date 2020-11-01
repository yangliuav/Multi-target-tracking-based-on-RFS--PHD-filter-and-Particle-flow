function vg = resampleRegularize(vg,ps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform resampling and add regularized noise if required.
%
% Inputs:
% vg: a struct that contains the filter output
% ps: structure with filter and simulation parameters
%
% Output:
% vg: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tt = ps.propparams.time_step;

weights = exp(vg.logW);
weights = weights/sum(weights);

eff = 1/sum(weights.^2);
vg.eff = eff;
if ps.setup.use_cluster || eff < ps.setup.Neff_thresh_ratio * ps.setup.nParticle
    I = resample(ps.setup.nParticle,weights,'stratified');
    vg.xp = vg.xp(:,I);
    vg.logW = zeros(size(I));

    if ps.setup.doplot
%         ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'weighted average');
        
        vg_tmp = vg;
        vg_tmp.xp_m = mean(vg.xp,2);
        ps.setup.plotfcn(vg_tmp,ps,zeros(size(vg.xp)),tt,'stratified resample');
    end
    
    if ps.setup.regularize_resample
        added_term = mvnrnd(zeros(size(vg.xp')),ps.propparams.Q_regularized);

        vg.xp = vg.xp + added_term';

        if ps.setup.doplot
            ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),tt,'regularized resample');
        end
    end
end