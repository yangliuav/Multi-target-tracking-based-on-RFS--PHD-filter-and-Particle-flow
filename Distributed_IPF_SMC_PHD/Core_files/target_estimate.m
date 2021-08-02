function Sensor = target_estimate(Sensor,setup)
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

% modification : remove the input argument

%%
t = setup.Example.propparams.time_step;
global_tno = Sensor.Tno;

weight_update_factor = Sensor.Tno/global_tno;
particle_state = Sensor.particle_state;
particle_weight = Sensor.particle_weight;
particle_weight = particle_weight * weight_update_factor;
particle_wlik = Sensor.particle_wlik;
inx = particle_weight>0.002;
Tno= round(sum(particle_weight(inx)));%global_tno;%
sumw = Sensor.sumw;
sumw2 = Sensor.sumw2;
vgset = Sensor.vgset;

if Tno~=0
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
        setup = plotting(setup,Sensor.idx,vgset,speakerx);
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
    else
%         vgset = vgset(inx);
    end
    Sensor.vgset = vgset;
    Sensor.output = speakerx;
else
    Sensor.vgset = vgset;
    Sensor.output = [];
end

    
end

