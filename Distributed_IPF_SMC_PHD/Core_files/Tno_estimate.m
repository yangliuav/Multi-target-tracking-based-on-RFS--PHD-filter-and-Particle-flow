function [Sensor,setup] = Tno_estimate(t,setup,iy,Sensor)
% This function implements proposed IPF-SMC-PHD algorithm by Dr. Yang Liu
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
% 
% Inputs:
% t: time stamp
% setup: algorithm setup
% iy: measurement in i-th sensor
% Sensor: particles set in i-th sensor
% 
% Outputs:

%%
clutter = 0.02;%0.0125;

setup.Example.propparams.time_step = t;

Sensor.vgset = SpawnAndBirthParticle(setup,Sensor,iy(t));
% propagate particles using prior and estimate the prior covariance matrix for particle flow filters.
[Sensor.vg,Sensor.vgset,setup] = propagateAndEstimatePriorCovariancePHD(Sensor,setup);
[Sensor.vgset,setup,Cz] = posteriorPHD(Sensor,setup,iy(:,t),clutter);


% %Sensor.vgset = SpawnAndBirthParticle(setup,Sensor);
% 
% % survive particles operation
% % propagate particles using prior and estimate the prior covariance matrix for particle flow filters.
% [Sensor.vg,Sensor.vgset,setup] = propagateAndEstimatePriorCovariancePHD(Sensor,setup);
% [Sensor.vgset,setup,Cz] = posteriorPHD(Sensor,setup,iy(:,t),clutter);
% 
% % birth model for new born particles based on measurement and update
% % weights
% [Sensor.vgset,numParticle] = birth_model(setup,iy(:,t),Cz,clutter,Sensor);
% 
% %% compare new born particle and survive particle to modify weights
% Sensor.vgset = compare_particle(Sensor,numParticle);

vgset = Sensor.vgset;        
sumw = 0;
sumw2 = 0;
for i = 1:size(vgset,2)
    sumw = sumw + vgset(i).w;
    sumw2 = sumw2 + (vgset(i).w)*(vgset(i).w);
end

Sensor.sumw = sumw;
Sensor.sumw2 = sumw2;

particle_state = zeros(4,size(vgset,2));
particle_weight = zeros(1,size(vgset,2));
particle_wlik = zeros(size(vgset,2),size(cell2mat(iy(:,t)),2)); % wlik

for i = 1:size(vgset,2)
    particle_state(:,i) = vgset(i).xp;
    particle_weight(:,i) = vgset(i).w;
    if size(vgset(i).wlik,2) == 1
        particle_wilk(i,:) = zeros(1,size(cell2mat(iy(:,t)),2));
        j = floor((i-numParticle)/setup.nParticle)+1;
        particle_wlik(i,j) = vgset(i).wlik;
    else
        for j = 1:size(cell2mat(iy(:,t)),2)
            particle_wlik(i,j) = vgset(i).wlik(j); % weight of likelihood?
        end
    end
end

Sensor.particle_state = particle_state;
Sensor.particle_weight = particle_weight;
Sensor.particle_wlik = particle_wlik;

inx = particle_weight>0.005;%0.002
Sensor.inx = inx;
Sensor.Tno=round(sum(particle_weight(inx)));

end

