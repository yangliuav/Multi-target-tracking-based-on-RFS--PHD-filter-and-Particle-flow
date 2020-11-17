function [start_frame, K]=start_end_frame_check(sequence,cam_number,K)
% This function provides frame numbers for start and end related to given sequence and cam
% number. 
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% -> sequence: The input sequence should be one of the following;
%                 -	seq24-2p-0111
%                 -	seq25-2p-0111
%                 -	seq30-2p-1101
%                 -	seq45-3p-1111
% -> cam_number: It indicates camera number 1, 2 or 3
% -> K: Number of video frames
% =========================================================================
% Outputs:
% -> start_frame    - frame number to start running.
% -> K              - Frame number to stop running.
% =========================================================================

if strcmp(sequence, 'seq24-2p-0111')
    if cam_number ==1
        start_frame     =   273;
    elseif cam_number ==2
        start_frame     =   301;
        K               =   1135;
    elseif cam_number ==3
        start_frame     =   254;        
    end
elseif strcmp(sequence, 'seq25-2p-0111')
    if cam_number ==1
        start_frame     =   86;
    elseif cam_number ==2
        start_frame     =   180;
        K               =   880;
    elseif cam_number ==3
        start_frame     =   104;  
    end  
elseif strcmp(sequence, 'seq30-2p-1101')
    if cam_number ==1
        start_frame     =   1;
    elseif cam_number ==2
        start_frame     =   1;
    elseif cam_number ==3
        start_frame     =   1;      
    end     
elseif strcmp(sequence, 'seq45-3p-1111')
    if cam_number ==1
        start_frame     =  302;        
    elseif cam_number ==2
        start_frame     =  360;
         K=1070;    
    elseif cam_number ==3
        start_frame     =  1;
        K=725;
    end
end