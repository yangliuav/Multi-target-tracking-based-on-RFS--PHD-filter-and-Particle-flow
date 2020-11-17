function id= check_id(x,image,model,seq_info)
% This function checks the identity of the detected speakers.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% x             -   state of the particles.
% image         -   image input.
% model         -   variables used in the phd filtering.
% seq_info      -   information about the sequence.
% =========================================================================
% Output:
% id             -   identity of the detected speakers.
% =========================================================================

%% id detection
id=[];
 [height, width, ~] = size(image); %Get the height and the width of the image 

%Convert the Image to HSV
if (model.HSV == 1)
    hsv_image = rgb2hsv(image);
end
ScoreMatrix=[];

    d=0;
  for j=1:seq_info.speaker
%     avgscale    =  avgscale + model.avgscale(j);
    d           =  d+ [ seq_info.(['dx_' num2str(j)]) seq_info.(['dy_' num2str(j)]) ];
  end 
  d =d / seq_info.speaker;

for j=1:size(x,2) % for each detected speaker
    
    for assume_speaker=1:seq_info.speaker % it is supposed to be template of reference histogram, but it doesnot matter
        
        y_lower = x(3,:) - round((d(2)/2)*x(5,:));
        y_upper = x(3,:) + round((d(2)/2)*x(5,:));
        x_lower = x(1,:) - round((d(1)/2)*x(5,:));
        x_upper = x(1,:) + round((d(1)/2)*x(5,:));
        
        %Cap all the limits to the image
        y_lower = round(cap(y_lower,1,height));
        y_upper = round(cap(y_upper,1,height));
        y_upper2 = round(cap(y_upper+30,1,height));
        x_lower = round(cap(x_lower,1,width));
        x_upper = round(cap(x_upper,1,width));        

        subimage    =   hsv_image( y_lower(j):y_upper2(j), x_lower(j):x_upper(j), : );
        cHist       =   hsvHist( subimage, model.bins  ); 
        ScoreMatrix(j,assume_speaker)  =  sqrt( 1 - sum(sum( sqrt(cHist.*seq_info.(['RefHist_id_' num2str(assume_speaker)])) ))); %#ok<AGROW>

    end
                  
end

T = size(ScoreMatrix,1);
D = size(ScoreMatrix,2);
AssignmentMatrix = zeros(T,D);
[currentScore, idxMin] = min(ScoreMatrix(:));

while(currentScore ~= 1)
 
    [tmin,dmin]                 = ind2sub(size(ScoreMatrix),idxMin);
    ScoreMatrix(tmin,dmin)      = 1;%#ok<AGROW>
    ScoreMatrix(tmin,:)         = 1;%#ok<AGROW>
    ScoreMatrix(:,dmin)         = 1;%#ok<AGROW>
    AssignmentMatrix(tmin,dmin) = 1;
    [currentScore, idxMin] = min(ScoreMatrix(:));
end

for i=1:j
    if find(AssignmentMatrix(i,:) ==1)
    id= [id find(AssignmentMatrix(i,:) ==1)];%#ok<AGROW>
    else  % in case extra speaker is detected, it will be annotated as 4
     id = [id 4]; %#ok<AGROW>
    end
end
