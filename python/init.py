#This file demonstrates how to initialize the algorithms

# Parameters:
# Init_PATH: Initialize file path
# DATA_PATH: dataset path
# setup: the setup information about the algorithms
# {
#   algs: the algorithms are used.
#   cam : the camera index of AV 16.3
#   sequence : the sequence name of AV 16.3
#   seed : the ramdon seed
#   resultsPath : the path of saving result.
#   colormodel : the color model 
#   bins       : the bin number of the histogram 
#   ospa_c : the parameter c of the OSPA
#   osps_p : the parameter p of the OSPA
#   initvel: the initial value of the vel 
#   sigma  : noise of variance
#   sigma_scale : variance of the noise of the scale parameter
#   Wk_resample : the resampled particle weight
#   Kflag : the name of the EKF method
#   resample :  whether resample particles
#   redraw : whether redraw particles
#   use_cluster : whether use cluster
#   maxilikeSAP : parameters for calculating the particle estimate
#   maxilikemode : the mode for calculating the particle estimate
#   nTrial : the times for running the experiments
#   weight_euclidean : the weight of Euclidean distances when performing clustering using 'euclidean_slope'
#   nParticleCluster : number of particle clusters used to calculate the slope
#   Neff_thresh_ratio : the thresh of ESS
#   nParticle : number of particles
#}
#inp: data information
#{
#   K : number of video frames
#   T : duration of each frame
#   Z_doa : DOA lines
#   Z_SRP : SRP-PHAT data
#   his_temp : histogram of the reference model 
#   angle_prev : the audio angle at last frame
#   start : the frame of start tracking
#}
#out:
#{
#   print_frame : whether print frame
#   plot_particles : whether plot particles on the frames
#   draw_audio : whether draw audio information ( DOA lines or SRP points)
#   save_frame : whether save frames 
#   save_data  : whether save experiment data
#}
#PFlow:
#{
#   lambda_type : the type of choosing lambda ('exponential'; 'uniform';)
#   nlambda : the number of lambda
#}
#PHD:
#{
#   x_dim : dimensionality of particle state
#   P_death : probability of speaker death 
#   P_detect : probability of detection in measurements or (1 - P_miss) 
#   F : Linear motion model
#   lambda_b : Average rate of speaker birth (per scan)
#   tilde_Xk : the initial particle state
#   bar_x : the born particle state
#   bar_B : the variance of born particle
#   lambda_c : average rate of clutter (per scan). 
#   range_c :  clutter intervals 
#   lambda_s : Average rate of speaker spawn (per scan)
#   lmax :  max. allowable particles
#   rho : no. of particles per survived speaker 
#   Jk : no. of particles for birth speakers
#   Lk : no. of sum wights
#   hat_N : hard estimate of the number of speakers
#   hat_N_soft : soft estimate of the number of speakers
#   hat_X : Cell for estimated positions of the speakers
#   chk_x : the state of peaker spawn
#   chk_F : fuction of peaker spawn
#   sigma_s :Sigma_scale of peaker spawn 
#   Q:  the covariance of particle for updating
#   L_b : the likelihood for born speaker
#   posn_interval :interval of speakers
#   H : the observation model
#   simTarget1State : the target state at frame 1 
#}
#PF:
#{
#   F : the equation of state
#   x_dim : the dimension of particle state
#   dimState_all : PF.x_dim*inp.nspeaker;
#   M : EKF1/EKF2/UKF estimate
#   PP : EKF1/EKF2/UKF pred. covariance
#   PU : EKF1/EKF2/UKF upd. covariance
#   xp : particle state
#   w :  particle weight
#   likeparams.R : the error of the likelihood
#}


# References:
# Y Liu, W. Wang
# "Audio-visual Zero Diffusion Particle FlowSMC-PHD Filter for Multi-speaker Tracking,"

#
# The codes & data have been deposited to https://github.com/jd0710/MNR-ADL-SR
#
# Written by Yang Liu, moderated by Wenwu Wang, version 1.0                                    
#
# If you have any questions or comments regarding this package, or if you want to 
# report any bugs or unexpected error messages, please send an e-mail to
# yangliu@surrey.ac.uk
#         
# Copyright 2017 Y Liu, W. Wang
# 
# This software is a free software distributed under the terms of the GNU 
# Public License version 3 (http://www.gnu.org/licenses/gpl.txt). You can 
# redistribute it and/or modify it under the terms of this licence, for 
# personal and non-commercial use and research purpose. 

import os

class Environment:
    def __init__(self):
        self.ospa_c = 40       # the parameter c of the OSPA
        self.ospa_p = 1        # the parameter p of the OSPA
        self.initvel = 4       # the initial value of the vel

        self.sigma = 50        # noise of variance
        self.sigma_scale = 0.1 # variance of the noise of the scale parameter

        self.Wk_resample     =   0;
#以下部分是否要放入构造函数里？
self.kflag           =   'EKF1';%'EKF1','regularized_identity',...'none'; % the method used to estimate the prior covariance.
self.resample        =   true;
self.redraw		  =   true;
self.use_cluster  = false;
self.maxilikeSAP	  =   200;
self.maxilikemode    =   'a';
self.nTrial		  =   5;
self.bins            =   16;
self.weight_euclidean = 0.25; % the weight of Euclidean distances when performing clustering using 'euclidean_slope'.
self.nParticleCluster = 100;% Number of particle clusters used to calculate the slope in the LEDH-variant algorithms.
self.Neff_thresh_ratio = 0.5;
self.nParticle = 50;
self.clutter = 2;
self.detect  = 0.99;
self.lambda_range = linspace(0,1,29);

def init(algorithms = "")
    if not algorithms:
        return
    if

# Path problem
path_lib=['ekfukf','particle_filter','particle_flow',
          'SmHMC','plotting','tools'
          'SMCPHD','Acoustic_Example','results',
          'Acoustic_Example']
for path in path_lib:
    if not os.path.exists(path):
        os.mkdir(path)