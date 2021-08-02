function dipf_smc_phd(input1,input2)
% This function implements proposed Distribtued IPF-SMC-PHD algorithm
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:


%% initialize algorithm
init_dipf;

%% generateMeasurements
setup = generateMeasurements(setup);
setup.x = setup.inp.x_all{ceil(1)}; % load GT
y = setup.inp.y_all; % load measurements

%% Initialize each sensor
sensor = {};
neighbor = find_neighbor(20,adjacency(setup.model.G));
for idxSensor = 1:setup.model.nAgent
    % smc-phd part
    [vg,vgset,output] = initializationFilterPHD(setup);
    sensor{idxSensor}.idx = idxSensor;
    sensor{idxSensor}.vg = vg;
    sensor{idxSensor}.vgset = vgset;
    sensor{idxSensor}.output = output;
    sensor{idxSensor}.ospa = [];
    % fusion part
    %node{i}.ID = i;
    sensor{idxSensor}.neighbor = neighbor{idxSensor};
    %node{i}.info = start_state(i);
    sensor{idxSensor}.recieve = []; % [node.ID,node.Info]
    sensor{idxSensor}.sent = [];
    sensor{idxSensor}.seen = [];
    sensor{idxSensor}.DoC =  0;
    sensor{idxSensor}.t = 1; % flooding iteration time step
end

%% Call for each IPF-SMC-PHD
% assume there is only agent in topology now
% Sensor = sensor{1};
% iy = y{1}; % read out i-th sensor measurement & i = 1
% Tno = [];
% for t = 1:setup.Example.T
%     % Step 1: Each sensor obtains local target number estimation
%     for idxSensor = 1:setup.model.nAgent
%         Sensor = sensor{idxSensor};
%         iy = y{idxSensor};
%         %[Sensor,setup] = Tno_estimate(t,setup,iy,Sensor);
%         [Sensor,setup] = tno_estimate_v1(t,setup,iy,Sensor);
%         sensor{idxSensor} = Sensor;
%     end
%     
%     % Step 2: Obtain global target number estimation
%     tno = [];
%     for idxSensor = 1:setup.model.nAgent
%         tno = [tno; sensor{idxSensor}.Tno];
%     end
%     global_tno = consensus_filter(tno,setup.model);
%     global_tno = round(mean(global_tno));
%     Tno = [Tno global_tno];
%     
    % Step 3: Global target nnumber update local particles
%     for idxSensor = 1:setup.model.nAgent
%         Sensor = sensor{idxSensor};
%         Sensor = target_estimate(Sensor,setup,global_tno);
%         output = Sensor.output;
% %         if size(output,2) ~= 4
% %             output = [output zeros(2,4-size(output,2))]
% %         end
%         GT = setup.inp.x_all{1}(:,t);
%         GT = reshape(GT,[4,4]);
%         GT = GT(1:2,:);
%         ospa = ospa_dist(output,GT,setup.inp.ospa_c,setup.inp.ospa_p)
%         Sensor.ospa = [Sensor.ospa ospa];
%         sensor{idxSensor} = Sensor;
%     end
% end
% 
% figure(10);hold on;
% title('target numbers estimation');
% plot(Tno);
% ylabel('Target Number');
% xlabel('Frame Number')
% 
% figure(11);hold on;
% title('OSPA in each sensor');
% for idxSensor = 1:setup.model.nAgent
%     plot(sensor{idxSensor}.ospa);
%     hold on;
% end
% ylabel('OSPA');
% xlabel('Frame Number');
% legend('Sensor-1','Sensor-2','Sensor-3','Sensor-4','Sensor-1');

for t = 1:setup.Example.T
    % Step 1: Each local sensor
    for idxSensor = 1:setup.model.nAgent
        Sensor = sensor{idxSensor};
        iy = y{idxSensor};
        %[Sensor,setup] = Tno_estimate(t,setup,iy,Sensor);
        [Sensor,setup] = Tno_estimate(t,setup,iy,Sensor);
        Sensor.info = Sensor.Tno;
        sensor{idxSensor} = Sensor;
    end
    
    % Step 2: Information exchanging and fusion
    sensor = flooding(sensor)
    for idxSensor = 1:setup.model.nAgent
        sensor{idxSensor}.Tno = floor(mean(sensor{idxSensor}.sent(:,2)));
    end
    
    % Step 3: Global target nnumber update local particles
        % Step 3: Global target nnumber update local particles
    for idxSensor = 1:setup.model.nAgent
        Sensor = sensor{idxSensor};
        Sensor = target_estimate(Sensor,setup);
        output = Sensor.output;
%         if size(output,2) ~= 4
%             output = [output zeros(2,4-size(output,2))]
%         end
        GT = setup.inp.x_all{1}(:,t);
        GT = reshape(GT,[4,4]);
        GT = GT(1:2,:);
        ospa = ospa_dist(output,GT,setup.inp.ospa_c,setup.inp.ospa_p)
        Sensor.ospa = [Sensor.ospa ospa];
        sensor{idxSensor} = Sensor;
    end

end

figure(30);hold on;
title('target numbers estimation');
plot(Tno);
ylabel('Target Number');
xlabel('Frame Number')
for idxSensor = 1:setup.model.nAgent
    leg(idxSensor) = sprintf('Sensor-%d',idxSensor);
end
xlim([1,setup.Example.T])
ylim([0,10])
legend(leg);

figure(40);hold on;
title('OSPA in each sensor');
for idxSensor = 1:setup.model.nAgent
    plot(sensor{idxSensor}.ospa);
    hold on;
end
ylabel('OSPA');
xlabel('Frame Number');
for idxSensor = 1:setup.model.nAgent
    leg(idxSensor) = sprintf('Sensor-%d',idxSensor);
end
xlim([1,20])
ylim([0,40])
legend(leg);



% tno = [];
% Sensor = sensor{1};
% for t = 1:setup.Example.T
%     % Step 1: Each local sensor obtains own estimation
%         
%     
%     iy = y{1};
%     Sensor = ipf_smc_phd(t,setup,iy,Sensor);
% 
%     tno = [tno Sensor.Tno];
%     GT = setup.inp.x_all{1}(:,t);
%     GT = reshape(GT,[4,4]);
%     GT = GT(1:2,:);
%     output = Sensor.output;
%     ospa = ospa_dist(output,GT,setup.inp.ospa_c,setup.inp.ospa_p)
%     Sensor.ospa = [Sensor.ospa ospa];
% end    
% 
% figure(10);hold on;
% title('target numbers estimation');
% plot(tno);
% xlim([1,setup.Example.T])
% ylim([0,4])
% xlabel('Frame Number')
% ylabel('Target Number Estimation')
% 
% figure(11);hold on;
% title('OSPA in each sensor');
% for idxSensor = 1:1%setup.model.nAgent
%     plot(Sensor.ospa);
%     hold on;
% end
% ylabel('OSPA')
% xlabel('Frame Number')
% xlim([1,setup.Example.T])
% ylim([0,40])
% legend();
% OSPA  = Sensor.ospa;

%     Step 2: Consensus filter to obtain global estimation
%     read out estimations from each sensor
%     target_pos = [];
%     for idxSensor = 1:setup.model.nAgent
%         if idxSensor ==1
%             target_pos = sensor{idxSensor}.Targetx;
%         end
%         temp = sensor{idxSensor}.Targetx;
%         [ti,tj] = size(temp);
%         [i_tar,j_tar] = size(target_pos);
%         if j_tar == tj
%             target_pos = [target_pos;temp];
%         else
%             if j_tar < tj
%                pad = zeros(2,(tj-j_tar));
%                target_pos = [target_pos pad];
%                target_pos = [target_pos;temo];
%             else %% solution is not good enough here
%                pad = zeros(2,(tj-j_tar));
%                temp = [temp pad];
%                target_pos = [target_pos;temp];
%             end
%         end
%     end
%     [~ , Tno] = size(target_pos);
%     con_tar = [];
%     for i = 1:Tno
%         tar_x = target_pos(1:2:(2*idxSensor));
%         tar_y = target_pos(2:2:(2*idxSensor));
%         up_tar_x = consensus_filter(tar_x,setup.model);
%         up_tar_y = consensus_filter(tar_y,setup.model);
%         temp_tar_i = [];
%         for j = 1:Tno
%             temp = [up_tar_x(i);up_tar_y(i)];
%             temp_tar_i = [con_tar;temp];
%         end
%         con_tar = [con_tar temp_tar_i];
%     end
%     for idxSensor = 1:setup.model.nAgent
%         sensor{idxSensor}.Targetx = con_tar((i*2-1):(i*2),:);
%     end
%     
%     % Step 3: Update Particles state of each sensor (NO MOVE, NO PFLOW)
%     for idxSensor = 1:setup.model.nAgent
%         Sensor = sensor{idxSensor};
%         g_estimation = Sensor.Targetx;
%         Sensor.vgset = post_p_weight_update(sensor,args,g_estimation);
%         sensor{idxSensor} = Sensor;
%     end
%     
%end


end

