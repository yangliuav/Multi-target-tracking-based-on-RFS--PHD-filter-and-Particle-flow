function angle=angle_check(sequence,cam_number,angle)
% This function checks the DOA azimuth angle whether it is inside the
% range of use.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% sequence    -     name of the sequence.
% cam_number    -   it indicates camera number: 1, 2 or 3.
% angle       -     DOA azimuth angle.
% =========================================================================
% Output:
% angle       -     DOA azimuth angle which is in the range    
% =========================================================================

if strcmp(sequence, 'seq24-2p-0111')
    if cam_number ==1;
        angle(angle>130)   =   [];  % Erase the DOA angle larger than 130 84
        angle(angle<-61)  =   [];  % Erase the DOA angle larger than -46 
    elseif  cam_number ==2
        angle(angle>95)       =   [];  % Erase the DOA angle larger than 95
        angle(angle<-53.40)   =   [];  % Erase the DOA angle larger than 95
    elseif cam_number ==3
        angle(angle>107)  =   [];  % Erase the DOA angle larger than 115
        angle(angle<-60.5)  =   [];  % Erase the DOA angle larger than -55
    end
    

elseif strcmp(sequence, 'seq45-3p-1111')

    if cam_number ==3
        % Third speaker leaves with 102 degree
        angle(angle>102)  =   [];  % Erase the DOA angle larger than 115
        angle(angle<-55)  =   [];  % Erase the DOA angle larger than -55
    end   
end