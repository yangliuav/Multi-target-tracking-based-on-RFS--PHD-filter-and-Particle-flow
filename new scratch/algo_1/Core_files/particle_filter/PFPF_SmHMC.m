function vg = PFPF_SmHMC(vg,ps,z_current)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SmHMC implementation modified from codes shared for [R1]:
%
% Input:
% vg: a struct that contains the filter output
% ps: a struct that contains model parameters.
% z_current: a measurement_dim x 1 vector of the current measurement
%
% Output:
% output: a struct that contains the filter outputs, including the particle
% estimate, true state, execution time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [R1]F. Septier and G. W. Peters, “Langevin and Hamiltonian based sequential
%    MCMC for efficient Bayesian filtering in high-dimensional spaces,”
%    IEEE J. Sel. Topics Signal Process., vol. 10, no. 2, pp. 312–327, Mar. 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModelParam = ps.SmHMC_model_params;
ModelParam.setup.doplot = ps.setup.doplot;
Observation = z_current;
%% codes modified from Septier and Peters

AlgoSeqMCMC = [];
BlockSize=ModelParam.Dimension; % Size Block in the refinement of SMCMC
mParticles=ModelParam.nParticle; % Number of particles that will be used in all Monte-Calro algorithms
AlgoSeqMCMC.NoParticles=mParticles; 
AlgoSeqMCMC.NoBurnIn=mParticles/10; % BurnIn Period SMCMC Set to 10% of NoParticles
AlgoSeqMCMC.Thining=1;

AlgoSeqMCMC.BothJointDraw_RefinementAtEachIteration=1; % 1 - Do both JD & Refin. Otherwise do JD with ProbaJointDraw and Ref. with Proba 1-ProbaJointDraw
AlgoSeqMCMC.ProbaJointDraw=0.75;
AlgoSeqMCMC.BlockSize=BlockSize; % Size of the Block in the refinement Step

ModelParam.AlphaPosDefMatrix=1e5;% To ensure positive definite matrix for the negative hessian of the log prior !!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choice between different techniques
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'PRIOR' -> Use independent proposal based on cond. prior
% 'optimal' -> only for Normal/Normal Case - Equivalent to Fully adapted Particle filter
% 'SMALA' -> Seq.  MALA with a Pre conditionned matrix, i.e. Unitary Identity Matrix
% 'SimplSmMALA' -> Seq. Manifold MALA with no drift 
% 'SmMALA' -> Seq. Manifold MALA 
% 'SHMC' -> HMC sampler with preconditionned Matrix to be defined below
% 'SmHMC' -> Seq. Manifold HMC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AlgoSeqMCMC.SamplingTechnique='SmHMC'; % Choose of the MCMC Kernel

AlgoSeqMCMC.NoLeapfrogSteps=20;% Number of Leapfrog Step in HMC-based sampling
AlgoSeqMCMC.StepSize=0.5;

AlgoSeqMCMC.NoFixedPointGeneLeapfrog=2; % Number of fixed point for Generalized Leapfrog
AlgoSeqMCMC.DisplayProposalCandidate=0; % To display at each MCMC iteration what are the proposed value for x

% Use in HMC - Preconditionned Matrix for Momentum Variables
AlgoSeqMCMC.CovAuxVarHMC=(1)*eye(ModelParam.Dimension);
AlgoSeqMCMC.InvCovAuxVarHMC=inv(AlgoSeqMCMC.CovAuxVarHMC);
AlgoSeqMCMC.SRInvCovAuxVarHMC=sqrtm(AlgoSeqMCMC.CovAuxVarHMC);

% To indicate wether the generalized leapfrog is necessary when mHMC is employed 
% Indeed not required when the metric does not depend on the state !!! Accelerate if not used 
% Example Normal/Normal Model || Normal/Poisson if the metric is
% obtained by expectation over the obs and data !
ModelParam.PoissonNormalPositionDependent=1; % if 1 we take the FIM of the poisson without marginalizing the X otherwise we marginalize with respect to X;

AlgoSeqMCMC.GeneralizedLeapfrogRequired=0;

if strcmp(ModelParam.setup.example_name,'Septier16')
    AlgoSeqMCMC.GeneralizedLeapfrogRequired=1;
end

% vg=SequentialMCMC_JointPosterior_after_PFPF(ModelParam,Observation,AlgoSeqMCMC,vg);
% vg=SmHMC_after_PFPF(ModelParam,Observation,AlgoSeqMCMC,vg);
vg=MCMC_after_PFPF(ModelParam,Observation,AlgoSeqMCMC,vg,ps);

% output.x_est = SeqMCMCParticles.Mean;
% output.AcceptanceRate = SeqMCMCParticles.Analysis.AcceptationRefinement/SeqMCMCParticles.Analysis.NoRefinement;

end