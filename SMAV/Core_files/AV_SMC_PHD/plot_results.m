% This function plot the results of the tracker.
% @ August 2016, University of Surrey

figure(1); clf; subplot(211); % number of speakers
% figure(2); clf; subplot(211); % x position trajectory
% figure(3); clf; subplot(211); % y position trajectory
figure(4); clf; subplot(211); % performance evaluation (ospa)

line_width  = 2;
font_label  = 15;
step_range  = 20;
marker_size = 12;
% start_frame =1;

%% Saving folder
main_cd     =   cd; % Get main folder direction.
cd(resultsPath );

date_time        = fix(clock);
folder_date_time =  [ num2str(date_time(1)) '-' num2str(date_time(2)) '-' num2str(date_time(3)) '-' num2str(date_time(4)) '-' num2str(date_time(5))];
while isdir(folder_date_time) % if the folder is already exist
  folder_date_time =[ num2str(date_time(1)) '-' num2str(date_time(2)) '-' num2str(date_time(3)) '-' num2str(date_time(4)) '-' num2str(date_time(5)) '-' num2str(randi(10,1,1))];  
end
mkdir(folder_date_time);
resultsPathtosave   =[resultsPath '/' folder_date_time '/' ];
cd(main_cd)

%%  plot the Number of target estimates

figure(1); %subplot(211); 
plot(start_frame:step_range:K,Data.posGT.N_speaker(start_frame:step_range:K),'Linewidth',line_width); hold on;
plot(start_frame:step_range:K,hat_N(start_frame:step_range:K),'or','Markersize',8,'Linewidth',line_width);   % !!!!!!
set( gca, 'fontsize', font_label );
set(gca, 'XLim',[start_frame K]); 
set(gca, 'YLim',[-0.5 max(max(hat_N,max(Data.posGT.N_speaker)))+0.5]);
xlabel('Frame Number','fontsize',font_label); 
ylabel('No. of speakers','fontsize',font_label);
title('Number of targets','FontWeight','normal')
legend('True','Estimated');

%% Position plot for the signal

% %--- plot true tracks
% for i=1:seq_info.speaker
%     figure(2); 
%     hline1  =   line(start_frame:step_range:K,Data.posGT.X_true(1,start_frame:step_range:K,i),'LineStyle','-','Marker','none',...
%          'LineWidth',2,'Color',0*ones(1,3));
%     hold on;  % x coordinates
%     figure(3);
%     hline2  =   line(start_frame:step_range:K,Data.posGT.X_true(3,start_frame:step_range:K,i),'LineStyle','-','Marker','none',...
%          'LineWidth',2,'Color',0*ones(1,3)); 
%      hold on;  % y coordinates
% end
% figure(2);
% set( gca, 'fontsize', font_label );
% xlabel('Frame Number','fontsize',font_label); 
% ylabel('x (in pixel)','fontsize',font_label);
% set(gca, 'XLim',[start_frame-20 K+20]); set(gca, 'YLim',[3 TrackedMov.Width]);
% 
% figure(3);
% set( gca, 'fontsize', font_label );
% xlabel('Frame Number','fontsize',font_label); 
% ylabel('y (in pixel)','fontsize',font_label);
% set(gca, 'XLim',[start_frame-20 K+20]); set(gca, 'YLim',[3 TrackedMov.Height]);
% 
% %--- plot SMC_PHD filter measurements
% iter=K;
% for k=start_frame:step_range:iter   
%     if ~isempty(hat_X{k})
%         P   = [1 0 0 0 0; 0 0 1 0 0]*hat_X{k};
%         
%         for i=1:size(P(1,:),2)
%         figure(2); 
%         %plot(k+start_frame-1,P(1,i),'ok','Linewidth',line_width); hold on;  % !!!!!!!!!!
%         hline3  =   line(k,P(1,i),'LineStyle','none','Marker','o',...
%              'LineWidth',.5,'Color',0*ones(1,3));
%         hold on; 
%         end
%         
%         for i=1:size(P(2,:),2)
%         figure(3); 
%         %plot(k+start_frame-1,P(2,i),'ok','Linewidth',line_width); hold on;  % !!!!!!!!!!
%         hline4  =   line(k,P(2,i),'LineStyle','none','Marker','o',...
%              'LineWidth',.5,'Color',0*ones(1,3)); hold on;  
%         end         
%         
%     end
% end
% figure(2);
% set( gca, 'fontsize', font_label );
% xlabel('Frame Number','fontsize',font_label); 
% ylabel('x (in pixel)','fontsize',font_label);
% set(gca, 'XLim',[start_frame-20 K+20]); set(gca, 'YLim',[3 TrackedMov.Width]);
% legend([hline3 hline1],'PHD filter estimates','True tracks');
% 
% figure(3);
% set( gca, 'fontsize', font_label );
% xlabel('Frame Number','fontsize',font_label); 
% ylabel('y (in pixel)','fontsize',font_label);
% set(gca, 'XLim',[start_frame-20 K+20]); set(gca, 'YLim',[3 TrackedMov.Height]);
% 
% legend([hline4 hline2],'PHD filter estimates','True tracks');

%%  plot the performance estimation

% OSPA-T

hat_track_list= cell(K,1);
for k=1:K
    if hat_N(k) == 7
    hat_track_list{k}   = [ 1 2 3 4 5 6 7];
    elseif hat_N(k) == 6
    hat_track_list{k}   = [ 1 2 3 4 5 6];
    elseif hat_N(k) == 5
    hat_track_list{k}   = [ 1 2 3 4 5];
    elseif hat_N(k) == 4
    hat_track_list{k}   = [ 1 2 3 4 ];
    elseif hat_N(k)== 3
    hat_track_list{k}   = [ 1 2 3];
    elseif hat_N(k) == 2
    hat_track_list{k}   = [ 1 2 ];
    else
    hat_track_list{k}   = [1];
    end
end

%[hat_X_track,~,~]   =   extract_tracks(hat_X,hat_track_list,Data.posGT.N_speaker);
[hat_X_track,~,~]   =   extract_tracks(hat_X,hat_track_list,seq_info.speaker);
[dist_ospa_t_vk ]   =   perf_asses_vk(Data.posGT.X_true(:,start_frame:K,:),hat_X_track(:,start_frame:K,:));  % Calculate OSPA

figure(4)
plot(start_frame:K,dist_ospa_t_vk ,'-r','Linewidth',line_width);
set( gca, 'fontsize', font_label );
xlabel('Frame Number','fontsize',font_label); 
ylabel('Ospa error','fontsize',font_label);
title(['Performance = ',num2str(mean(dist_ospa_t_vk)),' Seed number ',  num2str(seed_number)],'fontsize',font_label,'FontWeight','normal')
grid
set(gca, 'XLim',[start_frame K+20]); 
set(gca, 'YLim',[0 max(dist_ospa_t_vk )+5]);
 

%% Saving
if flag.save_plot_wspace 
saveas(figure(1), [resultsPathtosave  'num_speakers_' sequence '-cam' num2str(cam_number) '.png']  );
saveas(figure(1), [resultsPathtosave  'num_speakers_' sequence '-cam' num2str(cam_number) '.fig']  );

% saveas(figure(2), [resultsPathtosave  'x_pos_trajectory_' sequence '-cam' num2str(cam_number) '.png']  );
% saveas(figure(2), [resultsPathtosave  'x_pos_trajectory_' sequence '-cam' num2str(cam_number) '.fig']  );
% 
% saveas(figure(3), [resultsPathtosave  'y_pos_trajectory_' sequence '-cam' num2str(cam_number) '.png']  );
% saveas(figure(3), [resultsPathtosave  'y_pos_trajectory_' sequence '-cam' num2str(cam_number) '.fig']  );

saveas(figure(4), [resultsPathtosave  'ospa_' sequence '-cam' num2str(cam_number) '.png']  );
saveas(figure(4), [resultsPathtosave  'ospa_' sequence '-cam' num2str(cam_number) '.fig']  );

save([resultsPathtosave 'quick_workspace'], 'start_frame', 'K','dist_ospa_t_vk','Data','hat_N','hat_X','seed_number' , 'hat_X_marker')

end
