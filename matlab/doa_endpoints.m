function [Q5,Q6,m3]= doa_endpoints(cam_number,angle,Data,FrameNumber)
% This function calculates start and end points of the audio line.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% cam_number    -   camera number.
% angle         -   DOA azimuth angle.
% FrameNumber   -   current frame number.
% Data          -   contains GT, azimuth, timing, camera calibration.
%               -   information.
% =========================================================================
% Output:
% Q5            -   start points of the audio line.
% Q6            -   end points of the audio line.
% m             -   slope of the line. 
% =========================================================================


if cam_number == 1
    x_cord_init        =   290;        % initial audio for cam1
    y_cord_init        =   272;       % initial audio for cam1

elseif cam_number == 2
    x_cord_init        =   77;        % initial audio for cam2
    y_cord_init        =   204;       % initial audio for cam2    
    
elseif cam_number == 3
    x_cord_init        =   45;        % initial audio for cam3
    y_cord_init        =   179;       % initial audio for cam3    
    
end
    
width   =   360;
height  =   288;
Timing=Data.Timingcam;

Frame_time          =   Timing(FrameNumber,1);
Frame_cord_time     =   Frame_time+mod(Frame_time,1)*3;


temp_dist =[];
for i=1:length(fieldnames(Data.experiment))/2
    temp_gt=Data.experiment.(['ExGT' num2str(i)]);
    ind_cord            =   find(-0.01<(temp_gt(:,1)-Frame_cord_time+10),1);
    temp_dist = [temp_dist (angle-temp_gt(ind_cord,2))]; %#ok<AGROW>
end

if length(temp_dist)<2
    speaker_number =1;
else
    speaker_number=find( abs(temp_dist) == min(abs(temp_dist)));
end


Mouth3D=Data.MouthGT3D.(['person' num2str(speaker_number)]);

ind_cord            =   find(-0.01<(Mouth3D(:,1)-Frame_cord_time),1); % I need to send this data to calculate error
        
a       =   Mouth3D(ind_cord,3);
z       =   Mouth3D(ind_cord,5);%+0.05;       % Adding is neccessary to get mouth cord.

% z       =   0.8; % 1.8 - 0.84(table height)= 0.96

if angle >65
   b       =   Mouth3D(ind_cord,4);

else
    b       =   tand(angle)*a+0.4; 
end
p3d     =   [a b z 1]';                     % 3D coordinates
p2d     =   project(p3d,Data.cam,Data.align_mat);     % 2D coordinates for each camera
        
 %% Calculate endpoints for related cam
        x_cord_cam     =   p2d(cam_number,1);     % Get x position for cam# 
        y_cord_cam     =   p2d(cam_number,2);     % Get y position for cam#        
        
        [Q5, Q6,m3]        =   endpoints(x_cord_init,y_cord_init, x_cord_cam,y_cord_cam,width ,height); 