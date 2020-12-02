function lambda_range = generateExponentialLambda(nLambda,delta_lambda_ratio)
%% Calculate the exponentially spaced lambdas

if nargin < 2
    delta_lambda_ratio = 1.2;
end

lambda_1 = (1-delta_lambda_ratio)...
    /(1-delta_lambda_ratio^nLambda);
lambda_intervals = lambda_1*...
    delta_lambda_ratio.^[0:nLambda-1];
lambda_range = cumsum(lambda_intervals);

end

