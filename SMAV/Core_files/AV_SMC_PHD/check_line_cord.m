function [line_cord, bandwith_of_points]= check_line_cord(line_cord,line_x,line_y,doa_to_use, cam_number,sequence)
% This function cuts the some points which are over the audio line
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% line_cord     -   coordinates of the points laid on the auido line.
% line_x        -   x coordinates of the auido line points.
% line_y        -   x coordinates of the auido line points.
% doa_to_use    -   current doa to use.
% cam_number    -   it indicates camera number: 1, 2 or 3.
% sequence      -   name of the sequence.
% =========================================================================
% Output:
% line_cord             -   new points on the audio line.   
% bandwith_of_points    -   the bandwith to distribute particles around 
%                           the doa line.
% =========================================================================



if strcmp(sequence, 'seq24-2p-0111')
    if  cam_number == 1
        if doa_to_use < 0
            line_cord(line_y>190 | line_y <60 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        elseif doa_to_use < 90 && doa_to_use > 0 
            line_cord(line_y>190 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>190 | line_y <60 ,:) = [];
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 2
        line_cord(line_y>130 | line_y <50 ,:) = []; % Delete the points out of range
        bandwith_of_points  = 60;
    elseif cam_number == 3  
        if doa_to_use < -20
            line_cord(line_y>160 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>160 | line_y <60 ,:) = [];
            line_cord(line_x <160 ,:) = []; % Delete the points out of range

              bandwith_of_points  = 60;            
        elseif doa_to_use< 105 && doa_to_use > -20 
            line_cord(line_y>100 | line_y <30 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end

    end
    
elseif strcmp(sequence, 'seq25-2p-0111')
    if  cam_number == 1
        if doa_to_use < 0
            line_cord(line_y>190 | line_y <60 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        elseif doa_to_use < 90 && doa_to_use > 0 
            line_cord(line_y>190 | line_y <60 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 2
        line_cord(line_y>130 | line_y <50 ,:) = []; % Delete the points out of range
        bandwith_of_points  = 60;
    elseif cam_number == 3  
        if doa_to_use < -20
            line_cord(line_y>160 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>160 | line_y <60 ,:) = [];
            line_cord(line_x <160 ,:) = []; % Delete the points out of range

              bandwith_of_points  = 60;            
        elseif doa_to_use < 111 && doa_to_use > -20 %
            line_cord(line_y>100 | line_y <30 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end

    end

elseif strcmp(sequence, 'seq30-2p-1101')
    if  cam_number == 1
        if doa_to_use < 0
            line_cord(line_y>150 | line_y <60 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        elseif doa_to_use < 90 && doa_to_use > 0 
            line_cord(line_y>190 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>190 | line_y <60 ,:) = [];
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 2
        if doa_to_use < 0
            line_cord(line_y>150 | line_y <70 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_y>130 | line_y <50 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 3  
        if doa_to_use < -20
            line_cord(line_y>160 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>160 | line_y <60 ,:) = [];
            line_cord(line_x <160 ,:) = []; % Delete the points out of range

              bandwith_of_points  = 60;            
        elseif doa_to_use< 115 && doa_to_use > -20 
            line_cord(line_y>100 | line_y <50 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end

    end
elseif strcmp(sequence, 'seq45-3p-1111')
    if  cam_number == 1
        if doa_to_use < 0
            line_cord(line_y>130 | line_y <60 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        elseif doa_to_use < 80 && doa_to_use > 0 
            line_cord(line_y>150 | line_y <50 ,:) = []; % Delete the points out of range
            line_x(line_y>150 | line_y <50 ,:) = [];
            line_cord(line_x>270 | line_x <30 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        elseif doa_to_use < 90 && doa_to_use > 80 
        line_cord(line_y>210 | line_y <100 ,:) = []; % Delete the points out of range
        line_x(line_y>210 | line_y <100 ,:) = [];
        line_cord(line_x>270 | line_x <30 ,:) = []; % Delete the points out of range
        bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 2
        if doa_to_use < 0
            line_cord(line_y>150 | line_y <70 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_y>150 | line_y <50 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    elseif cam_number == 3  
        if doa_to_use < -20
            line_cord(line_y>160 | line_y <60 ,:) = []; % Delete the points out of range
            line_x(line_y>160 | line_y <60 ,:) = [];
            line_cord(line_x <160 ,:) = []; % Delete the points out of range

              bandwith_of_points  = 60;            
        elseif doa_to_use< 115 && doa_to_use > -20 
            line_cord(line_y>100 | line_y <50 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        else
            line_cord(line_x>280 | line_x <90 ,:) = []; % Delete the points out of range
            bandwith_of_points  = 60;
        end
    end       
end
