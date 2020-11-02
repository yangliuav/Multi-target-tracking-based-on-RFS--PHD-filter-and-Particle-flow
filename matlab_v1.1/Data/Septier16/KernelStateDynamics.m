
function [Covariance]=KernelStateDynamics(Locations,Param)

NbSensor=size(Locations,2);
CompleteMatrix1=repmat(Locations(1,:)',1,NbSensor);
CompleteMatrix2=repmat(Locations(2,:)',1,NbSensor);
NormLoc=((CompleteMatrix1-CompleteMatrix1').^2+(CompleteMatrix2-CompleteMatrix2').^2);

Covariance=Param(1)*exp(-NormLoc/Param(2));

% figure;imagesc(Covariance)