% This script defines initial parameters for the tracker.
% @ August 2016, University of Surrey

% =========================================================================
% Output:  
% model         -   variables used in the phd filtering. 
% seq_info      -   information about the sequence.
% TrackedMov    -   information about the video.
% K             -   number of video frames.
% Data          -   contains GT, azimuth, timing, camera calibration.
%               -   information.
% frame         -   contains frame with tracker output.
% =========================================================================

% Define a path to save your results images and make sure it exists
%resultsPath = './results/'; % One dot means going somewhere inside current folder
resultsPath =['./results/' sequence(1:5) '/cam' num2str(cam_number) '/'];

if ~isdir(resultsPath)
    mkdir(resultsPath);
end
addpath( resultsPath );     % Add the folder address to path
%*************************************************************************%
% i need to define them here, just because i need to call function "video_data"
% color histogram will come back with seq_info

model.HSV       =   1;  % HSV: 1 -> use HSV color model
                        %      0 -> use RGB color model
model.bins      =   16;  % bins: is the number of bins to use in the histogram

[seq_info, TrackedMov]  =   video_data(sequence,cam_number,model);
K                       =   TrackedMov.NumberOfFrames;  % Number of video frames

[start_frame, K]        =   start_end_frame_check(sequence,cam_number,K);


model.x_dim     =   5;      % Dimension of state vector
model.P_death   =   0.01;   % The probability of speaker death  
model.P_D       =   0.98;   % The probability of detection in measurements or (1 - P_miss) 
model.lambda_c  =   0.26;   % Average rate of clutter (per scan). 
model.range_c   =  [0 TrackedMov.Width; 0 TrackedMov.Height]; % clutter intervals 360 x 288

% Takes the particles as inputs x and applies the dynamic model to it.
% Xk+1 = FXk + Qk.
model.T         =   (1/TrackedMov.FrameRate);  % period between two adjacent frames
model.F         =   [1,model.T,0,0,0;           % Linear motion model
                    0,1,0,0,0; 
                    0,0,1,model.T,0; 
                    0,0,0,1,0;  
                    0,0,0,0,1];
model.invel     =   4;  % InVel: is the initial velocity of the particles
model.posn_interval =   [   0 TrackedMov.Width ;
                            0 model.invel;
                            0  TrackedMov.Height;
                            0 model.invel;
                            0 1];  % it should be 0 360; 0 288

model.sigma         =   50;     % Noise of variance
model.sigma_scale   =   0.1;    % Sigma_scale: is the variance of the noise of 
                            % the scale parameter.
                
 Q          =   [1, 0; 0, 1];
 Q          =   Q*model.sigma;
 model.Q    =   [Q, zeros(2,2) ,zeros(2,1); 
                zeros(2,2), Q ,zeros(2,1);
                zeros(1,2), zeros(1,2), model.sigma_scale]; 
clear Q;  % We do not need "Q" anymore            

%=== parameters for the observation 
model.C_posn    =   [ 1 0 0 0 0 ; 0 0 1 0 0 ];  

L_b                 = 1;                % no. of Gaussian birth terms
model.lambda_b      = zeros(L_b,1);     % Average rate of speaker birth (per scan)
model.bar_x         = zeros(model.x_dim,L_b);
model.lambda_b(1)   = 0.1; 
model.bar_x(:,1)    = [ 5; model.invel; 75; model.invel;1 ];  % These are initial points for the birth target states  !!!!
model.bar_B         = zeros(model.x_dim,model.x_dim,L_b); 
model.bar_B(:,:,1)  = diag([ 20; 5; 50; 5; 1 ]); % 70

%===here is the parameter for speaker spawn
L_s                 =   1;
model.lambda_s      =   zeros(L_s,1); % Average rate of speaker spawn (per scan)
model.chk_x         =   zeros(model.x_dim,L_s);
model.chk_F         =   zeros(model.x_dim,model.x_dim,L_s); 
model.sigma_s       =   zeros(L_s,1);
model.lambda_s(1)   =   0.1;  % 0.05
model.chk_x(:,1)    =   zeros(model.x_dim,1);  % No value has been assigned.
% In "gen_phistate_intensity_vk" it is considered that it should be zero 
% and new states are generated from existed states.
model.chk_F(:,:,1)  =   eye(model.x_dim); 
model.sigma_s(1)    =   1; % 10

%% PHD filter parameters
Lmax    = 1e5;      %   max. allowable particles
rho     = 50;      %   no. of particles per survived speaker 
Jk      = L_b*rho;  %   no. of particles for birth speakers

Lk              =   1;
hat_N           =   zeros(K,1);     % hard estimate of the number of speakers
hat_N_soft      =   zeros(K,1);     % soft estimate of the number of speakers
hat_X           =   cell(K,1);      % Cell for estimated positions of the speakers
tilde_Xk        =   model.bar_x(:,1);
Wk_resample     =   0;
%Z               =   cell(K,1);      % cell for storing measurements from face detector

% 
% %% ***********************************************************************%
% %                        Ground Truth Data
% %% ***********************************************************************%
% %% If audio is need to use  ^\/^
% % It contains Audio data, ExData and ExGT
% % It contains azimuth_seq##_s#
% Data=struct('experiment',load(['DataForSeq' sequence(4:5) '.mat']));% Changed
% %  Data=struct('experiment',load(['DataForSeq' sequence(4:5) '.mat']), ...
% %       'azimuth',load(['azimuth_' sequence(1:5) '.mat']) );
% 
% % Data=struct('azimuth',load(['azimuth_' sequence(1:5) '.mat']) );
% 
% 
% 
% % DOA data is needed to be projected to 2D, therefore we need following:
% Data.cam(1).Pmat = load('camera1.Pmat.cal', '-ASCII' );
% Data.cam(2).Pmat = load('camera2.Pmat.cal', '-ASCII' );  
% Data.cam(3).Pmat = load('camera3.Pmat.cal', '-ASCII' );
%  [ Data.cam(1).K, Data.cam(1).kc, Data.cam(1).alpha_c ] = readradfile( 'cam1.rad' );  
%  [ Data.cam(2).K, Data.cam(2).kc, Data.cam(2).alpha_c ] = readradfile( 'cam2.rad' );
%  [ Data.cam(3).K, Data.cam(3).kc, Data.cam(3).alpha_c ] = readradfile( 'cam3.rad' );
% 
%  %Load certain matrix transformation data
% load('rigid010203.mat');
% Data.align_mat=rigid.Pmat;
% clear rigid
% % If audio is needed to use, _/\_ 
% %% 
% 
% % Ground Truth data 3d mouth annotation
% % To draw audio line we need x and z cordinate of the speaker.
% % BallGT=fopen('seq11-1p-0100-person1.3dballgt','r');
% 
% for i=1:seq_info.speaker
%     MouthGT.(['person' num2str(i)]) =fopen([sequence '-person' num2str(i) '-interpolated.3dmouthgt'],'r');
% end
% 
% for i=1:seq_info.speaker
% k=0;
% % buff = str2num(fgetl(MouthGT.(['person' num2str(i)]))); %#ok<ST2NM>  % We dont want to get the first line of the mouthGT
%     while ~feof(MouthGT.(['person' num2str(i)]))
%         buff = str2num(fgetl(MouthGT.(['person' num2str(i)]))); %#ok<ST2NM>
%         if ~isempty( buff)
%            k = k+1;
%            Data.MouthGT3D.(['person' num2str(i)])(k,:) = buff;
%         end
%     end
% end
% 
% time_cam=fopen([sequence '_timings_cam' num2str(cam_number)],'r');
% %Timingcam3  = zeros(817,2);
% k=0;
% while ~feof(time_cam)
%     buff = str2num(fgetl(time_cam)); %#ok<ST2NM>
%     if ~isempty( buff)
%         k = k+1;
%         if length(buff) < 3  % if time reaches 60 sec, it gives error
%             Data.Timingcam(k,:) = buff;
%         else                 
%             Data.Timingcam(k,:) = buff(:,length(buff)-1:length(buff));
%         end
%     end
% end
% 
% Data.posGT.N_speaker= zeros(1,TrackedMov.NumberOfFrames);  % number of speaker in the scene
% % Data.posGT.X_true ==> Combination of speakers GT if they are in the scene
% for i=1:seq_info.speaker
% PositionGT.(['person' num2str(i)]) = fopen([sequence '-cam' num2str(cam_number) '-person' num2str(i) '-interpolated-reprojected.mouthgt'],'r');
% 
%     j=0;
%     while ~feof(PositionGT.(['person' num2str(i)]))
%         buff = str2num(fgetl(PositionGT.(['person' num2str(i)]))); %#ok<ST2NM>
%         if ~isempty( buff)
%            j = j+1;
%            Data.posGT.(['person' num2str(i)])(j,:) = buff([1 4:5]);  % time index, x-coord,  y-coord
% %            Data.posGT.X(:,j,i) = [round(buff(4)) 0 round(buff(5)) 0 0 ]';  % x-coord, 0,  y-coord, 0 0  
%            % Check whether speaker is in the view
%            if (round(buff(4)) > TrackedMov.Width) || (round(buff(5)) > TrackedMov.Height) || (round(buff(4)) < 1) || (round(buff(5)) < 1)
%              Data.posGT.X_true(:,j,i) = [0 0 0 0 0 ]';  % x-coord, 0,  y-coord, 0 0
%            else
%                Data.posGT.X_true(:,j,i) = [round(buff(4)) 0 round(buff(5)) 0 0 ]';  % time index, x-coord,  y-coord
%                Data.posGT.N_speaker(j) = Data.posGT.N_speaker(j)+1;  % Increment number of speaker
%            end           
%         end
%     end
% end
% clear PositionGT buff

load(['DOA_measurements_' sequence(1:5) '_cam' num2str(cam_number) '.mat'])
load(['data_av_' sequence(1:5) '_cam' num2str(cam_number)])

% Measurements
load(['hist_temp_' num2str(model.bins) 'bins_' sequence(1:5) '_cam' num2str(cam_number)])
Z= hist_temp;
clear hist_temp

if flag.print_frame
    frame.figure                =   figure(1);
    frame.av_smcphd         =   read(TrackedMov,start_frame ); % first image
    imshow(frame.av_smcphd);
    title('AV-SMC-PHD with color likelihood','FontSize',10,'FontWeight','normal');
    %xlabel(['Frame = ', num2str(start_frame), ' Seed number = ',  num2str(seed_number), ' rho = ', num2str(rho) ] )
    hold on;
end
