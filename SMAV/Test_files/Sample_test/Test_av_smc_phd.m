% This file demonstrates how to call the proposed av_smc_phd algorithm

% Inputs:
% -> sequence: The input sequence should be one of the following;
%                 -	seq24-2p-0111
%                 -	seq25-2p-0111
%                 -	seq30-2p-1101
%                 -	seq45-3p-1111
% -> cam_number: It indicates camera number 1, 2 or 3



clc; clear; close all;

%% Adding necessary files to the path
DATA_PATH = '../Core_files/Data';           % Point the folder where the data are located.
addpath( DATA_PATH );                       % Add the folder address to path
TRACKER_PATH = '../Core_files/AV_SMC_PHD';  % Point the folder where the tracker is located. 
addpath( TRACKER_PATH );                    % Add the folder address to path

%% Choosing sequence and cam number for tracker.
% As a demonstration, one sequences is given at the below 
% for two-speaker case.

sequence= char({ 'seq45-3p-1111'}); cam_number= 3;  % Two-spekaer case

%% Calling tracker
fprintf(['AV-SMC-PHD is running on ' sequence '-cam' num2str(cam_number) '\n'])
av_smc_phd(sequence,cam_number)
