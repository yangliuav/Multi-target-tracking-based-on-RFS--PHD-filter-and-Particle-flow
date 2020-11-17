function [image, tracker_marker] = drawRectangle(image, pos , avgscale ,d,color)%, fid )
% This function draws rectangle around the speakers.
% @ July 2013, University of Surrey

% =========================================================================
% Input:
% image         -   current frame of the video.
% pos           -   position of the related speaker.
% avgscale      -   coefficient for the dimension of the rectangle.
% d             -   dimension of the rectangle.
% color         -   color seperator for different speakers.
% =========================================================================
% Output:
% image             -   image with drawn rectangle.
% tracker_marker    -   coordinates of the points on the rectangel
% =========================================================================

tracker_marker  =   [];
color_flag      =   color;


if color == 1
    color = [0 255 0 ]; % Green
elseif color == 2
    color = [255 0 0 ]; % Red
elseif color == 3
    color = [0 0 255 ]; % Blue    
else
    color = [0 0 0 ]; % Black for false-detected speaker    
end

thickness= 2;
x1  =   cap(pos(1)-round(d(1)*avgscale),1,size(image,2));
x2  =   cap(pos(1)+round(d(1)*avgscale),1,size(image,2));
y1  =   cap(pos(2)-round(d(2)*avgscale),1,size(image,1));
y2  =   cap(pos(2)+round(d(2)*avgscale),1,size(image,1));

    for i=x1-thickness:x1+thickness   % left
        for j=y1:y2
            i_cap               = cap(i,1,size(image,2)); % check the border
            image(j,i_cap,:)    = color;
            tracker_marker      = [ tracker_marker ; [ j i_cap  color_flag ]];  %#ok<AGROW>
        end
    end
    
    for i=x2-thickness:x2+thickness  % right
        for j=y1:y2
            i_cap               = cap(i,1,size(image,2)); % check the border
            image(j,i_cap,:)    = color;
            tracker_marker      = [ tracker_marker; [ j i_cap  color_flag ]]; %#ok<AGROW>
        end
    end

    for j=y1-thickness:y1+thickness   % bottom
        for i=x1:x2
            j_cap               = cap(j,1,size(image,1)); % check the border
            image(j_cap,i,:)    = color;
            tracker_marker      = [ tracker_marker; [ j_cap i  color_flag ]];  %#ok<AGROW>
        end
    end   
  
    for j=y2-thickness:y2+thickness  %top
        for i=x1:x2
            j_cap= cap(j,1,size(image,1)); % check the border
           image(j_cap,i,:)= color;
           tracker_marker= [ tracker_marker;[ j_cap i  color_flag ]]; %#ok<AGROW>
        end
    end     
 
end