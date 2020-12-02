function  PP = shrinkageCov(xp)

cov_sample = cov(xp');
m_n = trace(cov_sample)/size(cov_sample,1);
identity_weighted = m_n*eye(size(cov_sample,1));
alpha_2_hat = (norm(cov_sample - identity_weighted))^2;
N_p = size(xp,2);
sample_cov_diff = 0;
sample_mean = mean(xp,2);
for i = 1:N_p
    sample_cov_diff = sample_cov_diff + (norm((xp(:,i)-sample_mean)*(xp(:,i)-sample_mean)'-cov_sample))^2;
end
alpha_1_hat = alpha_2_hat - min(alpha_2_hat,1/N_p^2*sample_cov_diff);
rho = alpha_1_hat/alpha_2_hat;

PP = rho*identity_weighted + (1-rho)*cov_sample;