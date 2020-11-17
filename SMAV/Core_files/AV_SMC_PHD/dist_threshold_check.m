function dist_threshold=dist_threshold_check(sequence,cam_number)
% This function calculates threshold distance to use in clustering.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% cam_number    -   it indicates camera number: 1, 2 or 3.
% sequence      -   name of the sequence.
% =========================================================================
% Output:
% dist_threshold -   threshold for distance.
% =========================================================================

if strcmp(sequence, 'seq24-2p-0111')
    if cam_number ==1
        dist_threshold = 40;  
    elseif cam_number == 2
        dist_threshold = 25; % 
    elseif cam_number ==3
        dist_threshold =30.5;  
    end
    
elseif strcmp(sequence, 'seq25-2p-0111') 
    if cam_number ==1
        dist_threshold = 31.2;  
    elseif cam_number == 2
        dist_threshold = 27; % 
    elseif cam_number ==3
        dist_threshold =41;  
    end
    
    
elseif strcmp(sequence, 'seq30-2p-1101')
    if cam_number ==1
        dist_threshold = 40;  
    elseif cam_number == 2
        dist_threshold = 25; % 
    elseif cam_number ==3
        dist_threshold =30;  
    end    
    
elseif strcmp(sequence, 'seq45-3p-1111')
    
    if cam_number ==1
        dist_threshold = 35;  
    elseif cam_number == 2
        dist_threshold = 25; % 
    elseif cam_number ==3
        dist_threshold = 25.3;  
    end
    
end