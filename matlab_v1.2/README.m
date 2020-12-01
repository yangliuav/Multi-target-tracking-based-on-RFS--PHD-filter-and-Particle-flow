%   Copyright 2016 Yunpeng Li and Mark Coates
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%
%   If you make use of this code in preparing results for a paper, please
%   cite: 
%
% 	[li2016] Y. Li and M. Coates, "Particle filtering with invertible particle flow",
%             arXiv: 1607.08799, 2016.
%
%
%   If you have any questions to this code, please contact Yunpeng Li at
%   yunpeng.li@mail.mcgill.ca
%
%   This code is tested on Matlab R2015b.
%   Date: 07/24/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code requires the following packages (in addition to standard
% Matlab toolboxes)
%
% EKF/UKF toolbox:
%
% http://becs.aalto.fi/en/research/bayes/ekfukf/
%
% This code also incorporates the code published at
% http://pagesperso.telecom-lille.fr/septier/MatlabCode_Septier_SMCMC.zip
% to evaluate the SmHMC algorithm proposed in
% [Septier16] F. Septier and G. W. Peters, “Langevin and Hamiltonian based sequential
%             MCMC for efficient Bayesian filtering in high-dimensional spaces,”
%             IEEE J. Sel. Topics Signal Process., vol. 10, no. 2, pp. 312–327, Mar. 2016.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The main folder provides the following primary functions
% 1. run(alg_executed)
%       This is the main function of the code.
%       It starts by initializating the simulation and
%       algorithm parameters, then runs each filter with
%       the required number of random trials.
%       The filter outputs are saved in a mat file.
%       alg_executed is a cell that can include the following algorithms.
%       PFPF_LEDH: the PFPF (LEDH) proposed in [li2016]
%       PFPF_EDH: the PFPF (EDH) proposed in [li2016]
%       LEDH: the localized Daum and Huang filter (LEDH)
%       EDH: the exact Daum and Huang filter (EDH)
%       GPFIS: the Gaussian particle flow particle filter (GPFIS)
%       SmHMC: the Sequential Markov chain Monte Carlo based on the
%              Manifold Hamiltonian Monte Carlo kernel (SmHMC).
%              Note that it can be only applied to the Septier16 example,
%              as it requires the target distribution to be log-concave.
%       EKF: the extended Kalman filter (EKF)
%       BPF: the bootstrap particle filter (BPF)
%
%       Two simulation setups are included and can be specified in initializePS.m:
%           'Acoustic', is the acoustic tracking example,
%           'Septier16' is the large sensor field tracking example reported in [Septier16].
%       See Section V of [Li2016] for more details.
%
% 2. plotErrors(file_name)
%       This function calculates filtering errors and display them.
%       file_name is a string that contains the name of the mat file that stores filter outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%