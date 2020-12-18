function [X, image] = concentrate_around_doa(X,Z,Data,flag,image,cam_number,FrameNumber)
% This function makes the particles concentrate around the DOA line
% and draw the DOA line if desired.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% X             -   particle set.
% Z             -   DOA azimuth angle.
% Data          -   contains GT, azimuth, timing, camera calibration.
%               -   information.
% flag          -   information for which flag needs to set. 
% image         -   currrent image.
% cam_number    -   camera number.
% FrameNumber   -   current frame number.
% =========================================================================
% Output:
% X             -   particle set.   
% =========================================================================

width   =   size(image,2);
height  =   size(image,1);
    
for i=1:length(Z)
    
    angle       =   Z(i);
    [Q5,Q6,m3]  =   doa_endpoints(cam_number,angle,Data,FrameNumber);  
    
    if flag  % If line is needed to be drawn      
        [line_x,line_y,~]   =   improfile(1,[ Q5(1) Q6(1)], [Q5(2) Q6(2)]);   % Get the coordinates lay on the audio line
        line_x              =   round(line_x);
        line_y              =   round(line_y);
        color               =   [255 255 0 ]; % yellow
        for k=1:length(line_x)        % Draw the line
            for j=line_x(k)-2 : line_x(k)+2
                j_cap                       =   cap(j,1,width);
                image(line_y(k),j_cap,:)    =   color;  
            end
        end
    end

    Q(i,:)=[Q5' Q6' m3]; 
end
% Q_name = ['Q' num2str(FrameNumber) '.mat'];
% save(Q_name,'Q')
%% Move the particles
 
% calculate min distances with line label
for i=1:size(X,2)  % For each particle

    P   =   X([1,3],i); % i th particle coordinate
    for j=1:length(Z)
        Q1          =   Q(j,1:2)';
        Q2          =   Q(j,3:4)';    
        dist_temp   =   abs(det([Q2-Q1,P-Q1]))/norm(Q2-Q1);    % Calculate  shortest distance to line
        if j>1 && (dist_temp < dist_line(1,i))             
            dist_line(1,i)  =   dist_temp;  % min distance %#ok<AGROW>
            dist_line(2,i)  =   j;           % label%#ok<AGROW>
        elseif j==1
            dist_line(1,i)  =   dist_temp;%#ok<AGROW>
            dist_line(2,i)  =   1;%#ok<AGROW>
        end
    end
end
    
dist_threshold  =   100; %!!!!!!!
idx             =   find(dist_line(1,:)>dist_threshold);
dist_line(1,idx)=   0;  %#ok<FNDSB> % Cancel the particles whose distance is more than threshold
dist_mov        =   dist_line(1,:)*0.2;
 
BD_cof =1; %!!!!!!
    
for i=1:size(X,2)

    if  dist_line(1,i)>0
        Q1  =   Q(dist_line(2,i),1:2)';
        Q2  =   Q(dist_line(2,i),3:4)';  
        m   =   Q(dist_line(2,i),5);

        % There are two angles perpendicular to line
        delta1  =   atand(m)+90+180;              % Angle of perpendicular line to Given line
        delta2  =   atand(m)-90+180;              % Angle of perpendicular line to Given line

        temp_P1(1,1)        =   X(1,i) + dist_mov(i)*cosd(delta1)*BD_cof;     % Spread particles x position
        temp_P1(2,1)        =   X(3,i) + dist_mov(i)*sind(delta1)*BD_cof;     % Spread particles y position 
        check_dist_delta1   =   abs(det([Q2-Q1,temp_P1-Q1]))/norm(Q2-Q1);        % Calculate distance to line
        

        % we need to check which delta is correct                  
        if check_dist_delta1 < dist_line(1,i)
            X(1,i)  =   temp_P1(1,1);
            X(3,i)  =   temp_P1(2,1);
        else 
%             X(1,i)  =   X(1,i) +dist_mov(i)*cosd(delta2)*BD_cof;   % Spread particles x position
%             X(3,i)  =   X(3,i) + dist_mov(i)*sind(delta2)*BD_cof;  % Spread particles y position  
            X(1,i)  =   X(1,i) + 0.5*dist_mov(i)*cosd(delta2)*BD_cof;   % Spread particles x position
            if 235-X(1,i)>5
                 X(1,i)  =   X(1,i) + 0.5*(235-X(1,i));
            end
            X(3,i)  =   X(3,i) + 0.5*dist_mov(i)*sind(delta2)*BD_cof
            if 84-X(3,i)>5
                X(3,i)  =   X(3,i)+ 0.5*(84-X(3,i));  % Spread particles y position   
            end
        end
    end
end
    
X(1,:)  =   round(cap(X(1,:), 1, width));
X(3,:)  =   round(cap(X(3,:), 1, height));    
