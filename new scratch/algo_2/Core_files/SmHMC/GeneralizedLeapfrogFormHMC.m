% Perform the Leapfrog integrator method for HMC
function [OutputData,OutputAuxVarHMC,InvNegHessian,NegHessian]=GeneralizedLeapfrogFormHMC(AuxVarHMC,ChosenData,Obs,MatrixTransformation,CurrentMean,ModelParam,Algo,IndexRefining,CondMean,InvCondCov)

OutputData=ChosenData;
OutputAuxVarHMC=AuxVarHMC;


for n=1:Algo.NoLeapfrogSteps

    
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Computation Gradient
    [Gradient]=ComputationGradient(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    %%%%%%%%%%%%%%%%%%%%%%
    % Computation Hessian
    [NegHessian,Veig,Deig,DeigTrans]=ComputationNegHessian(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    InvNegHessian=inv(NegHessian);
    %%%%%%%%%%%%%%%%%%%%%%
    % Computation of the Third Derivative
    [DerivativeNegHessian]=ComputationDerivativeNegHessian(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    
    %%%%%%%%%%%%%%%%%%%%%%      
    % Computation of the Derivative of the log determinant of log NegHessian
    DerivativeLogDeterminant=ComputationDerivativeLogDeterminant(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,Algo.BlockSize,ModelParam.AlphaPosDefMatrix,ModelParam);
    
    

    
    TempAux=OutputAuxVarHMC;
    for nn=1:Algo.NoFixedPointGeneLeapfrog  
        %%%%%%%%%%%%%%%%%%%%%%      
        % Computation of the Derivative of the inverse of the NegHessian
        DerivativeInvNegHessian=ComputationDerivativeInverseNegHessian(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,Algo.BlockSize,TempAux,ModelParam.AlphaPosDefMatrix,ModelParam);

        GradientRelatedToMetric=0.5*DerivativeLogDeterminant-0.5*DerivativeInvNegHessian;
       
        CurrentGradient=-Gradient+GradientRelatedToMetric;
        
        TempAux=OutputAuxVarHMC-(Algo.StepSize/2)*CurrentGradient;
    end
    
    
    OutputAuxVarHMC=TempAux;

    TempData=OutputData;
    for nn=1:Algo.NoFixedPointGeneLeapfrog

        %%%%%%%%%%%%%%%%%%%%%%
        % Computation Hessian
        if nn>1
            [NegHessian2]=ComputationNegHessian(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,TempData,ModelParam);
            InvNegHessian2=inv(NegHessian2);
        else
            InvNegHessian2=InvNegHessian;
        end   

        CurrentGradient=InvNegHessian*OutputAuxVarHMC+InvNegHessian2*OutputAuxVarHMC;
        
        TempData=OutputData+(Algo.StepSize/2)*CurrentGradient;   
    end
    
    OutputData=TempData;

    %%%%%%%%%%%%%%%%%%%%%%
    % Computation Gradient
    [Gradient]=ComputationGradient(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    %%%%%%%%%%%%%%%%%%%%%%
    % Computation Hessian
    [NegHessian,Veig,Deig,DeigTrans]=ComputationNegHessian(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    InvNegHessian=inv(NegHessian);
    %%%%%%%%%%%%%%%%%%%%%%
    % Computation of the Third Derivative
    [DerivativeNegHessian]=ComputationDerivativeNegHessian(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    
    %%%%%%%%%%%%%%%%%%%%%%      
    % Computation of the Derivative of the log determinant of log NegHessian
   DerivativeLogDeterminant=ComputationDerivativeLogDeterminant(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,Algo.BlockSize,ModelParam.AlphaPosDefMatrix,ModelParam);
    DerivativeInvNegHessian=ComputationDerivativeInverseNegHessian(InvNegHessian,DerivativeNegHessian,Veig,Deig,DeigTrans,Algo.BlockSize,OutputAuxVarHMC,ModelParam.AlphaPosDefMatrix,ModelParam);
   


    GradientRelatedToMetric=0.5*DerivativeLogDeterminant-0.5*DerivativeInvNegHessian;


    CurrentGradient=-Gradient+GradientRelatedToMetric;
        
    OutputAuxVarHMC=OutputAuxVarHMC-(Algo.StepSize/2)*CurrentGradient;
    
    


    
end
