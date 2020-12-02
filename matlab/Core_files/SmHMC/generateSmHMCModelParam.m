function ModelParam = generateSmHMCModelParam(ps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the model parameters for different examples
%
% Input:
% ps: a structure that contains simulation and filter parameter values
%
% Output:
% ModelParam: a struct that contains the model parameter values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModelParam.nParticle=ps.setup.nParticle;
ModelParam.NoTimeSteps=ps.setup.T; % No Of Time Steps
ModelParam.Dimension=ps.setup.dimState_all; % Dimension of X_k

ModelParam.initparams = ps.initparams;
ModelParam.propparams = ps.propparams;
ModelParam.likeparams = ps.likeparams;
ModelParam.setup = ps.setup;

switch ps.setup.example_name
    case 'Septier16'
        % By increasing the size of the domain with dimension I keep the
        % correlation between 2 consecutives cases equal
        ModelParam.Domain=[1 sqrt(ModelParam.Dimension)];%[0 30];

        ModelParam.NbSensors=ModelParam.Dimension; % Dimension of Y_k 

        ModelParam.initialization_method = 'delta';

        % Sensors placed on a regular grid
        [Xsensors,YSensors]=meshgrid(linspace(ModelParam.Domain(1),ModelParam.Domain(2),sqrt(ModelParam.NbSensors)));
        ModelParam.SensorPosition=reshape(Xsensors,1,[]);
        ModelParam.SensorPosition=[ModelParam.SensorPosition;reshape(YSensors,1,[])];

        ModelParam.TransitionMatrix_alpha = 0.9;
        ModelParam.TransitionMatrix=ModelParam.TransitionMatrix_alpha*eye(ModelParam.Dimension);
        ModelParam.ObservationTransition=eye(ModelParam.Dimension); % Required to Map supp(X_k) to supp(Y_k)


        ModelParam.StateCovParam(1)=3; % Variance
        % ModelParam.InitialMean=log(10)*ones(ModelParam.Dimension,1);%log(100)*ones(ModelParam.Dimension,1);
        ModelParam.InitialMean=zeros(ModelParam.Dimension,1);%log(100)*ones(ModelParam.Dimension,1);
        init_mean = mean(ModelParam.InitialMean);
        ModelParam.StateCovParam(2)=20; % Length scale of the exp in Correlation
        ModelParam.StateCovParam(3)=0.01; %in Normal/Normal
        ModelParam.StateCovariance=KernelStateDynamics(ModelParam.SensorPosition,ModelParam.StateCovParam);


        ModelParam.StateCovariance=ModelParam.StateCovariance+ModelParam.StateCovParam(3)*eye(ModelParam.Dimension);


        ModelParam.StateCovariance=triu(ModelParam.StateCovariance,1)+triu(ModelParam.StateCovariance,1)'+diag(diag(ModelParam.StateCovariance));
        ModelParam.StateCovarianceSR=real(sqrtm(ModelParam.StateCovariance));
        ModelParam.StateCovarianceInv=real(inv(ModelParam.StateCovariance));
        ModelParam.StateCovarianceDet=real(det(ModelParam.StateCovariance));

        ModelParam.StateSkewness=0.3*ones(ModelParam.Dimension,1); % Skewness when GH Skewed-t Used
        ModelParam.StateDegreeFreedom=7;% \nu Degree Freedom when GH Skewed-t Used
        % Computation of Covariance SkewedtT
        a=ModelParam.StateDegreeFreedom/2;
        b=a;
        MeanW=b/(a-1);
        VarW=(b^2)/(((a-1)^2)*(a-2));
        ModelParam.StateCovSkewedT=MeanW*ModelParam.StateCovariance+VarW*ModelParam.StateSkewness*ModelParam.StateSkewness';
        ModelParam.InvStateCovSkewedT=inv(ModelParam.StateCovSkewedT);   


        ModelParam.MappingIntensityFunction=@(x,Coeff,Scale) Coeff*exp(x/Scale);
        ModelParam.MappingIntensityFunctionFirstDeriv=@(x,Coeff,Scale) Coeff*exp(x/Scale)/Scale;
        ModelParam.MappingIntensityFunctionSecDeriv=@(x,Coeff,Scale) Coeff*exp(x/Scale)/(Scale^2);
        ModelParam.MappingIntensityFunctionThirdDeriv=@(x,Coeff,Scale) Coeff*exp(x/Scale)/(Scale^3);
        ModelParam.MappingIntensityFunctionLog=@(x,Coeff,Scale) log(Coeff)+(x/Scale);
        ModelParam.MappingIntensityFunctionFirstDerivLog=@(x,Coeff,Scale) (1/Scale)*ones(size(x));
        ModelParam.MappingIntensityFunctionSecDerivLog=@(x,Coeff,Scale) zeros(size(x));


        ModelParam.MappingIntensityCoeff=1;
        ModelParam.MappingIntensityScale=3;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Choice between different likelihood
        % 'Poisson' -> Indepedent Poisson Observations
        % 'Normal' -> Indepedent Normal Observations
        %
        % Choice between different State
        % 'SkewedT' -> Multivariate Skewed T distribution
%         ModelParam.ModelObservation='Poisson';%'Poisson';
%         ModelParam.ModelState='SkewedT';
    case 'Acoustic'
        ModelParam.StateCovariance = ModelParam.propparams.Q;
        ModelParam.StateCovarianceInv = inv(ModelParam.StateCovariance);
    otherwise
end
