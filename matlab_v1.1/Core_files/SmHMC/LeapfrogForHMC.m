% Perform the Leapfrog integrator method for HMC
function [OutputData,OutputAuxVarHMC]=LeapfrogForHMC(AuxVarHMC,ChosenData,Obs,MatrixTransformation,CurrentMean,ModelParam,Algo,IndexRefining,CondMean,InvCondCov,MatrixInvCovAuxVarHMC)

OutputData=ChosenData;
OutputAuxVarHMC=AuxVarHMC;


for n=1:Algo.NoLeapfrogSteps 
    [Gradient]=ComputationGradient(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    
    OutputAuxVarHMC=OutputAuxVarHMC+((Algo.StepSize)/2)*Gradient;
    
    OutputData=OutputData+Algo.StepSize*MatrixInvCovAuxVarHMC(IndexRefining,IndexRefining)*OutputAuxVarHMC;
    
    [Gradient]=ComputationGradient(Obs,MatrixTransformation,Algo.BlockSize,CondMean,InvCondCov,OutputData,ModelParam);
    
    OutputAuxVarHMC=OutputAuxVarHMC+((Algo.StepSize)/2)*Gradient;    
end