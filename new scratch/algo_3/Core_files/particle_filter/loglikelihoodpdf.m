function [g,chisq]=loglikelihoodpdf(y,z,P0,numTargets,likeparams)
% Calculate log of d-dimensional Gaussian and exponential prob. density evaluated at xp 
% with mean x0 and covariance P0
%
% xp: particles: dimensions d by N
% x0: mean: d by 1
% P0: covariance: d by d
%
% g: evaluation of the log-pdf
% chisq: the likelihood of range
% bearinglik: the likelihood of bearing
% likelihood =
% 1/((2*pi*beta.^2).^(numTargets/2)*det(P0)^0.5)*exp{-0.5*(r(k+1)-r_hat(k+1))'*inv(P0)*(r(k+1)-r_hat(k+1))}*exp{-(1/beta)*(theta(k+1)-tan(y(k+1)/x(k+1)))}
% for one target

% updated by Lingling Zhao for the bearing and range measurement model.

[d,N]=size(y);
g=zeros(1,N);
beta = likeparams.beta;
%
twopi_factor=(2*pi*beta.^2)^(numTargets/2);
detP_factor=det(P0(1:numTargets,1:numTargets))^0.5;
delta_y = y(:,:)-z(:,:)*ones(1,N);

%
if N >1
     P = inv(P0(1:numTargets,1:numTargets));
     for i=1:N,
          chisq(i,1) = sum(delta_y(1:numTargets,i)'*P *delta_y(1:numTargets,i));
     end;
     bearinglik = -(1/beta)*sum(delta_y(numTargets+1:2*numTargets,:));
else
     chisq=sum(delta_y(1:numTargets,:).*(P0P0(1:numTargets,1:numTargets)\delta_y(1:numTargets,:)),1);
     bearinglik = -(1/beta)*sum(delta_y(numTargets+1:2*numTargets,:));
end;

coeff1 = log(twopi_factor);
coeff2 = log(detP_factor);
%
g= -(chisq'/2) - coeff1*ones(1,N) -coeff2*ones(1,N) + bearinglik; % 1 by N






