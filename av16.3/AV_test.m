%%  Clear environment
close all;
clear all;
clc;

%%  Point Data storage and load Data
folder = fileparts(mfilename('fullpath'));
addpath(genpath(folder));

% load video
seq_name = 'seq45-3p-1111_cam1_divx_audio.avi';
%global video;
video = VideoReader(seq_name);

%% load Data object contains GT and camera model info etc.
data_name = 'data_av_seq45_cam1.mat'
load(data_name);
% swap Data.posGT.X_true to fit our state format
Data.posGT.X_true([1 3 2 4 5],:,:) = Data.posGT.X_true([1 2 3 4 5],:,:);
Data.posGT.X_true(5,:,:) = [];
%Data.posGT.X_true = reshape(Data.posGT.X_true(:,:,:),[1 12 video.NumFrames]);
Data.posGT.X_true = [Data.posGT.X_true(:,:,1);Data.posGT.X_true(:,:,2);Data.posGT.X_true(:,:,3)];
% Data.posGT.X_true = reshape(Data.posGT.X_true(:,:,:),[12,video.NumFrames]); % error line

% load the face detection result
face_name = 'face_seq45_cam1.mat';
load(face_name);

doa_name = 'DOA_measurements_seq45_cam1.mat';
load(doa_name);

%%  Initial Algorithm
initialize;

%%  Generate Measurements
setup = generateMeasurements(setup,video,Data,face);
%%  PHD filtering
output = cell(setup.nTrial,1);

for trial_ix=1:setup.nTrial
    setup.trial_ix = trial_ix;
    output{trial_ix} = run_one_trial(setup,trial_ix,video,Z_doa);        
end







% for idx = 2:K
%     run_one_trail;
% end


% for idx_frm = 1:video.NumFrames
%    figure(1)
%    frame = readFrame(video);
%    imshow(frame); 
%    title(sprintf('Current Frame index: %d', idx_frm));
%    if ~isempty(face{idx_frm})
%        t_face = face{idx_frm};
%        [i,j] = size(t_face);
%        for n = 1:i
%            a = t_face(n,:);
%            rectangle('Position',[a(1),a(2),(a(3)-a(1)),(a(4)-a(2))],'EdgeColor','r');
%        end
%    end
%    hold on;
% end
