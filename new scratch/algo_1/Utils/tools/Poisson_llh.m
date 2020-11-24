function llh = Poisson_llh(xp,z_current,likeparams)

    m1 = likeparams.mappingIntensityCoeff;
    m2 = likeparams.mappingIntensityScale;
    alpha = likeparams.observationTransition;

    lambda=m1*exp(alpha*xp/m2);

    llh=z_current'*log(lambda)-sum(lambda,1);
end

