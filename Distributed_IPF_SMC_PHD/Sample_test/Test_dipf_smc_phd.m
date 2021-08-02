% This file demonstrates how to call the proposed distributed ipf_smc_phd
% algorithm

% Inputs:

clc; clear; close all;

%% Adding necessary files to the path
% DATA_PATH = '';
% addpath( DATA_PATH );
TRACKER_PATH = '../Core_files';
addpath( TRACKER_PATH );
UTILS_PATH = '../Utility';
addpath( UTILS_PATH );

cd('..');
root_path = pwd;
% addpath(genpath(root_path));
%% Select input data

%% Calling tracker
fprintf('Distributed IPF-SMC-PHD is runing');
dipf_smc_phd(1,1)