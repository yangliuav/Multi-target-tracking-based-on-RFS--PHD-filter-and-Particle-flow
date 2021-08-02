function Sensor = ipf_smc_phd(t,setup,iy,Sensor)
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
% Sensor.vgset = SpawnAndBirthParticle_v1(setup,Sensor.vgset);

% survive particles operation
% propagate particles using prior and estimate the prior covariance matrix for particle flow filters.
[Sensor.vg,Sensor.vgset,setup] = propagateAndEstimatePriorCovariancePHD(Sensor,setup);
[Sensor.vgset,setup,Cz] = posteriorPHD(Sensor,setup,iy(:,t),clutter);

% birth model for new born particles based on measurement and update
% weights
% [Sensor.vgset,numParticle] = birth_model(setup,iy(:,t),Cz,clutter,Sensor);

% compare new born particle and survive particle to modify weights
% Sensor.vgset = compare_particle(Sensor,numParticle);




vgset = Sensor.vgset;        
sumw = 0;
sumw2 = 0;
for i = 1:size(vgset,2)
    sumw = sumw + vgset(i).w;
    sumw2 = sumw2 + (vgset(i).w)*(vgset(i).w);
end

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

inx = particle_weight>0.005;%0.002;
Tno=round(sum(particle_weight(inx)))

use_particle_num = size(find(inx==1),2)
temp_inx = find(inx==1);

if Tno ~= 0 && (use_particle_num > Tno)
    speakerx1 = cluster(particle_state(:,inx),Tno);
    speakerx  = speakerx1(1:2,:);
    ESS(t) =  sumw*sumw/sumw2; % ESS treshold: check resample or not  

    if isfield(setup.inp,'x_all')
        xx = cell2mat(setup.inp.x_all);
        xxt  =xx(:,t);
        for i = 1:size(xxt,1)/4
            truex([1,2],i) = xxt([(i-1)*4+1,(i-1)*4+2],1);
        end  
    end
    setup.inp.title_flag = 'bef_resamp';
    if 1%setup.out.print_frame
        
        for i = 1:use_particle_num
            p_vgset(i).xp = vgset(temp_inx(i)).xp;
        end
        setup = plotting(setup,Sensor.idx,p_vgset,speakerx);
    end

    if ESS(t) < 0.5*Tno*50
        Lk                  =   min(round(Tno*50),200);
        idx                 =   my_resample(particle_weight(1,:)'/sumw,Lk);
        particle_state_resample   =   particle_state(:,idx);
        particle_state            =   particle_state_resample; 
        particle_weight           =   particle_weight(:,idx);
        particle_wlik             =   particle_wlik(idx,:);
        particle_weight          = Tno* particle_weight/sum(particle_weight);
        vgset = {};
        for i = 1:size(particle_state,2)
            vgset(i).xp = particle_state(:,i);
            vgset(i).PP = zeros(4,4);
            vgset(i).PU = blkdiag(100,100,1,1);
            vgset(i).M  = vgset(i).xp;
            vgset(i).xp_m = vgset(i).xp;
            vgset(i).w  = particle_weight(:,i);
            vgset(i).PD = 1; % remove later
            vgset(i).B = 0;
        end
    else
       [w,del]=sort(-particle_weight);
       Ndel = size(del,2) - Tno*50;
       if Ndel >0
        vgset(del(size(del,2):-1:size(del,2)-Ndel+1))= [];
       end
    end

    setup.inp.title_flag = 'Esti_Resamp'
    if 0%setup.out.print_frame
        plotting(setup,Sensor.idx,vgset,speakerx)
%     else
%         vgset = vgset(inx);
    end
    
elseif (use_particle_num<Tno)
    [Sensor.vg,Sensor.vgset,Sensor.output] = initializationFilterPHD(setup); % Re-initialize

end

% if Tno ~= 0 
%     Sensor.Targetx = Sort(speakerx);
% else
%     Sensor.Targetx = [];
% end
Sensor.Tno = Tno;
if Tno ~= 0 && (use_particle_num > Tno)
    Sensor.output = speakerx;
elseif (use_particle_num<Tno)
    Sensor.output = [];
else
    Sensor.output = [];
end


end

