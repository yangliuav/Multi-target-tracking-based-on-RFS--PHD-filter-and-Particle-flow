function [Q1 ,Q2, m]= endpoints(x_cord_init1,y_cord_init1,x_cord,y_cord,width,height)
% This function calculates start and end points of the audio line.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% x_cord_init1  -   microphone array position on the 2D image.
% y_cord_init1  -   microphone array position on the 2D image.
% x_cord        -   2D points of azimuth angle.
% y_cord        -   2D points of azimuth angle.
% width         -   width of the image.
% height        -   height of the image.
% =========================================================================
% Output:
% Q1            -   start points of the audio line.
% Q2            -   end points of the audio line.
% m             -   slope of the line.
% =========================================================================

endpoints   =   [];

% Find m and n in y=m*x+n
m = (y_cord - y_cord_init1 )/(x_cord - x_cord_init1);   % slope of the line 
n = y_cord_init1 - m*x_cord_init1;

% Find endpoints of line 
temp_y = m*1 + n;
if temp_y <= height && temp_y >=1  % Check y whether inside the image
    endpoints =[endpoints ; 1 temp_y];
end

temp_y = m*width + n;
if temp_y <= height && temp_y >=1  % Check y whether inside the image
    endpoints =[endpoints ; width temp_y];
end

temp_x =(1-n)/m ;
if temp_x <= width && temp_x >=1  % Check x whether inside the image
    endpoints =[endpoints ;  temp_x 1];
end

temp_x = (height-n)/m ;
if temp_x <= width && temp_x >=1  % Check x whether inside the image
    endpoints =[endpoints ; temp_x height];
end
        
 Q1     = endpoints (1,:)';
 Q2     = endpoints (2,:)';
 