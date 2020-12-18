%%  Clear environment
close all;
clear all;
clc;

%%  Point Data storage and load Data
folder = fileparts(mfilename('fullpath'));
addpath(genpath(folder));

% load the video data
seq_name = 'seq45-3p-1111_cam1_divx_audio.avi';
global video;
video = VideoReader(seq_name);

% load the face detection data
face_name = 'face_seq45_cam1.mat';
load(face_name);

%%  Initial Algorithm
initialize;

%%  Generate Measurements

