function [LogLikelihood]=ComputationLogNormal(Obs,Mean,InvCov,Cov)

% Normal Linear Model

LogLikelihood=-0.5*((Obs-Mean)'*InvCov*(Obs-Mean))-0.5*logdet(Cov, 'chol');

