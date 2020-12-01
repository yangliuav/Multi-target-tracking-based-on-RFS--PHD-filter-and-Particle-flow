function [estimate,ml_weights] = particle_estimate(log_weights,particles,maxilikeSAP,maxilikemode,approxexpflag)
% Form estimate based on weighted set of particles
%
% log_weights: logarithmic weights [Nx1]
% particles: the state values of the particles [dim x N] (state dimension x
% number of particles)
% maxilikeSAP: use a reduced set of particles specified by this number
% maxilikemode: 'm'= median, 'a' = weighted means
% approxexpflag: use a polynomial approximation to the exp function
%
if nargin<5
    approxexpflag=0;
end

if nargin<4
    maxilikemode = 'a';
end

% discard particles with inf or nan values in estimating the particle mean
particle_inf_nan = logical(sum((isinf(particles)|isnan(particles)),1));
particles(:,particle_inf_nan) = [];
log_weights(particle_inf_nan) = [];

[dim,N]=size(particles);
if nargin<3
    maxilikeSAP = N;
end

% sort the log weights
[sorted_log_weights,I]=sort(log_weights);

% number of particles to use 
% minimum of number of finite weights and maxilikeSAP
SAP=min([sum(~isinf(sorted_log_weights)) maxilikeSAP]);


if strcmp(maxilikemode,'m')
    % in median case, just pick the median value for each state dimension
    estimate=median(particles(:,I(N-SAP+1:N)),2);


elseif strcmp(maxilikemode,'a')
    % select subset of particles - those with heighest weight
    ml_log_weights=sorted_log_weights(N-SAP+1:N);
    
    % exponentiate weights
    if approxexpflag
        ml_weights= approx_expo(ml_log_weights);
    else
        ml_weights = exp(ml_log_weights);
    end
    %
    if sum(ml_weights)==0
        ml_weights = ones(size(ml_weights));
    end

    ml_weights=ml_weights/sum(ml_weights);
    
    ml_weights_multiple=ones(dim,1)*ml_weights;
    
    estimate=sum(particles(:,I(N-SAP+1:N)).*ml_weights_multiple,2);

end

end