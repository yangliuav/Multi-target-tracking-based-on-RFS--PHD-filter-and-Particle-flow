% This script is designed for temporate test [ print out real data frame]

%% load the video data
seq_name = './Data/seq45/seq45-3p-1111_cam1_divx_audio.avi';

v = VideoReader(seq_name);

%% load the doa data
doa_name = './Data/seq45/DOA_measurements_seq45_cam1.mat';
load(doa_name);

%% load the face detection data
face_name = './Data/seq45/face_seq45_cam1.mat'
load(face_name);

%% load Data object contains GT and camera model info etc.
data_name = './Data/seq45/data_av_seq45_cam1.mat'
load(data_name);
%% read video frame and play video
for k = 1:v.numFrames
   figure(1)
   frame = readFrame(v);
   imshow(frame);
   % angle check is not essential needed here
   % doa_check
   if isempty(Z_doa{k})
       doa_status = 'None';
   else
       doa_status = 'Existed';
   end
   % face check
   if isempty(face{k})
       face_status = 'None';
   else
       face_status = 'Existed';
   end
   title(sprintf('Current Frame index: %d, DOA: %s, Face: %s', k, doa_status, face_status));
   if ~isempty(face{k})
       t_face = face{k};
       [i,j] = size(t_face);
       for n = 1:i
           a = t_face(n,:);
           rectangle('Position',[a(1),a(2),(a(3)-a(1)),(a(4)-a(2))],'EdgeColor','r');
       end
   end
   hold on;
end

%% try to apply doa operation in SMAV on our data

% for k = 1:v.numFrames
%     angle = angle_check(sequence,cam_number,Z_doa{k});
%     if ~isempty(angle) % doa angle value existed
%         % collect Matrix Q from concentrate_on_doa
%         [Q5 Q6 m3] = doa_endpoints(cam_number,angle,Data,k);
%     end
% end
