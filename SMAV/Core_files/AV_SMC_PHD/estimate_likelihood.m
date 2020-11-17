function [color_likelihood] = estimate_likelihood(x, image, model ,seq_info,RHist)
% This function estimates the likelihood.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% x             -   state of the particles.
% image         -   image input.
% model         -   variables used in the phd filtering.
% seq_info      -   information about the sequence.
% RHist         -   reference histogram.
% =========================================================================
% Output:
% color_likelihood  -   color likelihood.
% =========================================================================

D_threshold = 0.55;

[height, width, ~] = size(image); %Get the height and the width of the image 

%Convert the Image to HSV
if (model.HSV == 1)
    hsv_image = rgb2hsv(image);
end
    %hue, saturation and value...

D   =   zeros(size(RHist,1),size(x,2));

% In the case of multi speaker, particle are checked for every
% reference image and best results are taken 

d   =   0;
 
for j=1:seq_info.speaker
    d           =  d+ [ seq_info.(['dx_' num2str(j)]) seq_info.(['dy_' num2str(j)]) ];
end        
 
d =d / seq_info.speaker;
     

y_lower = x(3,:) - round((d(2)/2)*x(5,:));
y_upper = x(3,:) + round((d(2)/2)*x(5,:));
x_lower = x(1,:) - round((d(1)/2)*x(5,:));
x_upper = x(1,:) + round((d(1)/2)*x(5,:));
%Cap all the limits to the image
y_lower = round(cap(y_lower,1,height));
y_upper = round(cap(y_upper,1,height));
x_lower = round(cap(x_lower,1,width));
x_upper = round(cap(x_upper,1,width));        
        
        if(model.HSV)% Use the HSV model
            for i=1:size(x,2)
                subimage    =   hsv_image( y_lower(i):y_upper(i), x_lower(i):x_upper(i), : );
                cHist       =   hsvHist( subimage, model.bins  );
                for j=1:size(RHist,1)
                D(j,i)        =   sqrt( 1 - sum(sum( sqrt(cHist.*RHist{j}) )));
                end

                [sorted_D, idx_D] =sort(D(:,i));
                cumsum_sorted_D= cumsum(sorted_D);

                D(:,i)= cumsum_sorted_D(idx_D);   % cumulative sum
                D(D(:,i)<D_threshold,i)=0.394968; % it will make e_sq= 15.6 then color_likelihood becomes 0.0016
                D(D(:,i)>D_threshold,i)=D(D(:,i)>D_threshold,i)*4;

            end
        else% use RGB model
            for i=1:size(x,2)
            subimage    =   image( y_lower(i):y_upper(i), x_lower(i):x_upper(i), : );
            cHist       =   colorHist( subimage, model.bins  );
            D_temp      =   sqrt( 1 - sum(sum( sqrt(cHist.*RHist) )));
            D(i)        =   min(D(i),D_temp);

            end
        end

% Likelihood model is taken from :
% A Color-based Particle Filter for Joint Detection and Tracking of
% Multiple objects
     scale   = 1;
     sigma_v = 0.1; 
     e_sq=((D*scale)/sigma_v).^2;
     color_likelihood = exp(-e_sq/2)/(sigma_v*sqrt(2*pi));
end