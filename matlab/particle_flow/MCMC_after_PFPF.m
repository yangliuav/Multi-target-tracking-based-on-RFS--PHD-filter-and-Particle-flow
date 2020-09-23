function vg=MCMC_after_PFPF(ModelParam,Observation,Algo,vg,ps)

Particles.Analysis.NoRefinement=0;
Particles.Analysis.AcceptationRefinement=0;
Particles.Analysis.NoJointDraw=0;
Particles.Analysis.AcceptationJointDraw=0;
Particles.Analysis.AcceptationPreviousTerm=0;
Particles.Analysis.NoPreviousTerm=0;
NoMCMCIterations=Algo.NoBurnIn+Algo.Thining*Algo.NoParticles;
NoRefiningSteps=ModelParam.Dimension/Algo.BlockSize;

Particles.Data=zeros(ModelParam.Dimension,Algo.NoParticles);
Particles.AuxVarHMC=zeros(ModelParam.Dimension,Algo.NoParticles);
Particles.Mean=zeros(ModelParam.Dimension,1);


Candidate.Data=zeros(ModelParam.Dimension,1);
Candidate.LogLikelihood=0;

Chosen.Data=zeros(ModelParam.Dimension,1);
Chosen.LogLikelihood=0;


switch ModelParam.setup.example_name
    case 'Acoustic'
        propparams_no_noise = ModelParam.propparams;
        propparams_no_noise.Q = 0*ModelParam.propparams.Q;
    case 'Septier16'
        propparams_no_noise.W = 0;
    otherwise
        error('The example name does not matche the record');
end

weights = exp(vg.logW);
weights = weights/sum(weights);

I = resample(1,weights,'stratified');       
state = vg.xp(:,I);
prob_state=ModelParam.likeparams.llh(state,Observation,ModelParam.likeparams);
vg_tmp = [];
vg_tmp.xp = repmat(state,1,size(vg.xp,2));

% Propagate the particles one step, without introducing dynamic noise.
propparams_no_noise = ps.propparams;
switch ps.setup.example_name
    case 'Acoustic'
        propparams_no_noise.Q = 0*ps.propparams.Q;
    case 'Septier16'
        propparams_no_noise.W = 0;
    otherwise
        error('The example name does not matche the record');
end
vg_tmp.xp_prop_deterministic = ps.propparams.propagatefcn(vg.xp_prev,propparams_no_noise);

log_prior_state = log_process_density(vg_tmp,ps);
prob_state = prob_state + log(sum(exp(log_prior_state)));

nAccept = 0;
N_MCMC = ps.setup.N_MCMC;
xp_chosen = zeros(length(state),N_MCMC);
for j=1:N_MCMC % MCMC iteraion for one time sample
%     I = resample(1,weights,'stratified');   
    added_term = mvnrnd(zeros(size(state')),ps.propparams.Q_regularized);
    candidate = state + added_term';
    prob_candidate=ModelParam.likeparams.llh(candidate,Observation,ModelParam.likeparams);
    vg_tmp.xp = repmat(candidate,1,size(vg.xp,2));
    log_prior_candidate = log_process_density(vg_tmp,ps);
    prob_candidate = prob_candidate + log(sum(exp(log_prior_candidate)));
    
    if rand < exp(prob_candidate-prob_state)
        state = candidate;
        prob_state = prob_candidate;
        nAccept = nAccept + 1;
    end
    
    xp_chosen(:,j) = state;    
end

vg.xp_m = particle_estimate(zeros(1,N_MCMC),xp_chosen,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % form state estimate
vg.xp = xp_chosen(:,sort(randperm(N_MCMC,length(weights))));
['Acceptance rate: ', num2str(nAccept/N_MCMC)]

vg.logW = zeros(1,size(vg.xp,2));
    
if ModelParam.setup.doplot
    pause(0.1)
    ps.setup.plotfcn(vg,ps,zeros(size(vg.xp)),ps.propparams.time_step,'After MCMC'); % call plot function  
end