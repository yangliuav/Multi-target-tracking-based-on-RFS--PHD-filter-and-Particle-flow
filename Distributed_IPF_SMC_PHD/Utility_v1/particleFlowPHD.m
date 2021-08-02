function vgset = particleFlowPHD(sensor,setup,z_current,Cz,surv_particle_num,nSi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function performs particle flow and resampling (if needed)
%
% Inputs:
% vg: a struct that contains the filter output
% ps: structure with filter and simulation parameters
% z_current: a column vector of the measurements at the current time step.
%
% Output:
% vg: a struct that contains the filter output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps = setup.Example;
tt = ps.propparams.time_step;
vgset = sensor.vgset;
idxSensor = sensor.idx
lambda_prev = 0;
% jExampleobian_det_prod is calculated for PFPF (LEDH) weight update.
log_jExampleobian_det_sum = zeros(1,setup.nParticle);
H = setup.inp.H;
lm = zeros(1,surv_particle_num);%zeros(1,size(vgset,2));

for i = 1:surv_particle_num
    [~,lm(:,i)] = max(vgset(i).llh); % lm find the max likelihood index in 6 (4 tar and 2 clutter)
end

particle_state = zeros(4,size(vgset,2));
particle_weight = zeros(1,size(vgset,2));
mm = zeros(4,size(z_current,2));
PP = zeros(4,4,size(z_current,2));
t= 0;
vgsetpre = vgset;

for lambda = setup.lambda_range
    % Calculate the slopes used to migrate particles
    step_size = lambda-lambda_prev;
    t= t+1;
    %ps = updateMeasurementCov(vg.xp_auxiliary_individual,ps);
    if  size(vgset,1) ~= 0
        [slope, log_jExampleobian_det] = calculateSlopePHD(z_current,vgset,setup,lambda,step_size,surv_particle_num,Cz,nSi);
    end
    if max(abs(slope(:,1))) < 0.2 && lambda ~=0
        break;
    end
    for i = 1:surv_particle_num%size(vgset(),2)
        % pflow moves particles
        if size(slope(:,i),1)== 2
            vgset(i).xp = vgset(i).xp + step_size*H*slope(:,i);
        else
            vgset(i).xp = vgset(i).xp + step_size*slope(:,i);  % Euler update of particles
        end
        particle_state(:,i) = vgset(i).xp;
        particle_weight(:,i) = vgset(i).w;
    end
    
    
    for i = 1:size(z_current,2)
        Cz(:,i) = 0;
        for j = 1:surv_particle_num%size(vgset,2)
            vgset(j).llh(:,i) =  Gaussian_llh_PHD(vgset(j).xp,z_current(:,i),setup.Example.likeparams);
                        
            if(vgset(j).llh(:,i)>1)
                vgset(j).llh(:,i) =1;
            end
            Cz(:,i) = Cz(:,i) + vgset(j).llh(:,i)* vgset(j).w;
        end   
    end
    % Calculate the sum of the log JExampleobian determinants used in weight update
%     log_jExampleobian_det_sum = log_jExampleobian_det_sum + log_jExampleobian_det;
%     log_jExampleobian_det_sum = log_jExampleobian_det_sum - max(log_jExampleobian_det_sum);
    
    % if we only perform clustering before the flow,
    % there is no need to update vg.xp_auxiliary_individual
%     vg.xp_auxiliary_individual = vg.xp_auxiliary_individual + step_size*slope.auxiliary_individual;

    
    %vg.xp_m = particle_estimate(vg.logW,vg.xp,ps.setup.maxilikeSAP,ps.setup.maxilikemode); % current state estimate 
    lambda_prev = lambda;
        
    setup.inp.title_flag = 'SMCPHD'
    if setup.out.print_frame
        plotting(setup,idxSensor,vgset,lambda);
    end

end

for i = 1:surv_particle_num%size(vgset,2)
%     minu = bsxfun(@minus,vgset(i).xp,vgsetpre(i).xp);
%     m = minu(1)^2 + minu(2)^2;
%     m = m^(1/2);
%     w = sum(normpdf(m,0,10));
    vgset(i).w = vgset(i).w;
end
%% Add a noise to the auxiliary variables and then evaluate the weights.
%vgset = correctoinAndCalculateWeightsPHD(vgset,setup,z_current);
end