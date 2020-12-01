function ps = updateMeasurementCov(xp,ps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the state-dependent variance for the Septier 16 example.
%
% Input:
% xp: a matrix containing particle values
% ps: a struct with filter and simulation parameters
%
% Output:
% ps: a struct with filter and simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch ps.setup.example_name
    case {'Septier16'}
        % R is the same as the measurement here
        cov_all_particles = ps.likeparams.h_func(xp,ps.likeparams);
        nMeasurement = size(cov_all_particles,1);
        nParticle = size(cov_all_particles,2);
        ps.likeparams.R = zeros(nMeasurement,nMeasurement,nParticle);
        for particle_ix = 1:nParticle
            ps.likeparams.R(:,:,particle_ix) = diag(cov_all_particles(:,particle_ix));
        end
end