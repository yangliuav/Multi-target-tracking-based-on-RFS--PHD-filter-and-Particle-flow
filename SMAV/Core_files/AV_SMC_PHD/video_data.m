function [seq_info, TrackedMov]= video_data(sequence,cam_number,model)
% This function extracts the informatin related to given sequence and cam
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
% -> model:  model variables which we need the value of bins of HSV
% =========================================================================
% Outputs:
%% TrackedMov    : Video information
% TrackedMov.Width, 
% TrackedMov.VideoFormat,
% TrackedMov.NumberOfFrames,
% TrackedMov.Height,
% TrackedMov.FrameRate,
% TrackedMov.BitsPerPixel,
% TrackedMov.UserData,
% TrackedMov.Type,
% TrackedMov.Tag,
% TrackedMov.Path,
% TrackedMov.Name,
% TrackedMov.Duration

%% seq_info      : Sequence information
% seq_info.RefHist_#,
% seq_info.dy_#,
% seq_info.dx_#,
% seq_info.y0_#,
% seq_info.x0_#,
% seq_info.LF,  % Last Frame
% seq_info.IF,  % Initial Frame
% seq_info.speaker   % Number of speaker

%% d given in video_data is one side of the rectangle, not the distance from center of the rectangle

%*************************************************************************%
%                        Frame Information
%*************************************************************************%
% TrackedMov  =  VideoReader(['transcoded_' sequence '_cam' num2str(cam_number) '_divx_audio.avi']);
TrackedMov  =  VideoReader([sequence '_cam' num2str(cam_number) '_divx_audio.avi']);


if strcmp(sequence, 'seq24-2p-0111')
    seq_info.speaker    = 2;        % Number of speakers in the sequence
        
    if cam_number == 1
        seq_info.IF     = 315;       % Initial frame for seq24-2p-0111 cam1
        seq_info.x0_1   = 284 ;     % initial x position
        seq_info.y0_1   = 85 ;      % initial y position
        seq_info.x0_2   = 199 ;     % initial x position
        seq_info.y0_2   = 97 ;      % initial y position
        seq_info.LF     = 500;      % Last frame for seq24-2p-0111 cam1
        seq_info.dx_1   = 18;       % Initial x scale
        seq_info.dy_1   = 28;       % Initial y scale
        seq_info.dx_2   = 24;       % Initial x scale
        seq_info.dy_2   = 34;       % Initial y scale  
        
    elseif cam_number == 2
        seq_info.IF     = 315;       % Initial frame for seq24-2p-0111 cam2
        seq_info.x0_1   = 286 ;     % initial x position
        seq_info.y0_1   = 97 ;      % initial y position
        seq_info.x0_2   = 100 ;     % initial x position
        seq_info.y0_2   = 83 ;      % initial y position
        seq_info.LF     = 528;      % Last frame for seq24-2p-0111 cam2
        seq_info.dx_1   = 18;       % Initial x scale
        seq_info.dy_1   = 29;       % Initial y scale
        seq_info.dx_2   = 15;       % Initial x scale
        seq_info.dy_2   = 23;       % Initial y scale  
        
    elseif cam_number == 3
        seq_info.IF     = 260;       % Initial frame for seq24-2p-0111 cam3
        seq_info.x0_1   = 267 ;     % initial x position
        seq_info.y0_1   = 86 ;      % initial y position
        seq_info.x0_2   = 94 ;     % initial x position
        seq_info.y0_2   = 58 ;      % initial y position
        seq_info.LF     = 481;      % Last frame for seq24-2p-0111 cam3
        seq_info.dx_1   = 28;       % Initial x scale
        seq_info.dy_1   = 39;       % Initial y scale
        seq_info.dx_2   = 16;       % Initial x scale
        seq_info.dy_2   = 22;       % Initial y scale  
        
    end
elseif strcmp(sequence, 'seq25-2p-0111')
    seq_info.speaker    = 2;        % Number of speakers in the sequence
    
    if cam_number == 1
        seq_info.IF     = 125;       % Initial frame for seq25-2p-0111 cam1
        seq_info.x0_1   = 284 ;     % initial x position
        seq_info.y0_1   = 101 ;      % initial y position
        seq_info.x0_2   = 65 ;     % initial x position
        seq_info.y0_2   = 95 ;      % initial y position
        seq_info.LF     = 225;      % Last frame for seq25-2p-0111 cam1
        seq_info.dx_1   = 20;       % Initial x scale
        seq_info.dy_1   = 37;       % Initial y scale
        seq_info.dx_2   = 35;       % Initial x scale
        seq_info.dy_2   = 46;       % Initial y scale  
        
    elseif cam_number == 2
        seq_info.IF     = 210;       % Initial frame for seq25-2p-0111 cam2
        seq_info.x0_1   = 194 ;     % initial x position
        seq_info.y0_1   = 98 ;      % initial y position
        seq_info.x0_2   = 64 ;     % initial x position
        seq_info.y0_2   = 82 ;      % initial y position
        seq_info.LF     = 351;      % Last frame for seq25-2p-0111 cam2
        seq_info.dx_1   = 23;       % Initial x scale
        seq_info.dy_1   = 33;       % Initial y scale
        seq_info.dx_2   = 17;       % Initial x scale
        seq_info.dy_2   = 23;       % Initial y scale  
        
    elseif cam_number == 3
        seq_info.IF     = 80;       % Initial frame for seq25-2p-0111 cam3
        seq_info.x0_1   = 206 ;     % initial x position
        seq_info.y0_1   = 92 ;      % initial y position
        seq_info.x0_2   = 25 ;     % initial x position
        seq_info.y0_2   = 62 ;      % initial y position
        seq_info.LF     = 270;      % Last frame for seq25-2p-0111 cam3
        seq_info.dx_1   = 28;       % Initial x scale
        seq_info.dy_1   = 36;       % Initial y scale
        seq_info.dx_2   = 15;       % Initial x scale
        seq_info.dy_2   = 22;       % Initial y scale  
        
    end
elseif strcmp(sequence, 'seq30-2p-1101')
    seq_info.speaker    = 2;        % Number of speakers in the sequence
    
    if cam_number == 1
        seq_info.IF     = 128;       % Initial frame for seq30-2p-1101 cam1
        seq_info.x0_1   = 257 ;     % initial x position
        seq_info.y0_1   = 83 ;      % initial y position
        seq_info.x0_2   = 340 ;     % initial x position
        seq_info.y0_2   = 113 ;      % initial y position
        seq_info.LF     = 248;      % Last frame for seq30-2p-1101 cam1
        seq_info.dx_1   = 22;       % Initial x scale
        seq_info.dy_1   = 31;       % Initial y scale
        seq_info.dx_2   = 17;       % Initial x scale
        seq_info.dy_2   = 24;       % Initial y scale  
        
    elseif cam_number == 2
        seq_info.IF     = 90;       % Initial frame for seq30-2p-1101 cam2
        seq_info.x0_1   = 225 ;     % initial x position
        seq_info.y0_1   = 89 ;      % initial y position
        seq_info.x0_2   = 337 ;     % initial x position
        seq_info.y0_2   = 137 ;      % initial y position
        seq_info.LF     = 195;      % Last frame for seq30-2p-1101 cam2
        seq_info.dx_1   = 22;       % Initial x scale
        seq_info.dy_1   = 29;       % Initial y scale
        seq_info.dx_2   = 29;       % Initial x scale
        seq_info.dy_2   = 32;       % Initial y scale  
        
    elseif cam_number == 3
        seq_info.IF     = 60;       % Initial frame for seq30-2p-1101 cam3
        seq_info.x0_1   = 214 ;     % initial x position
        seq_info.y0_1   = 76 ;      % initial y position
        seq_info.x0_2   = 325 ;     % initial x position
        seq_info.y0_2   = 154 ;      % initial y position
        seq_info.LF     = 145;      % Last frame for seq30-2p-1101 cam3
        seq_info.dx_1   = 24;       % Initial x scale
        seq_info.dy_1   = 35;       % Initial y scale
        seq_info.dx_2   = 43;       % Initial x scale
        seq_info.dy_2   = 43;       % Initial y scale  
        
    end
    

elseif strcmp(sequence, 'seq45-3p-1111')
    seq_info.speaker    = 3;        % Number of speakers in the sequence
    
    if cam_number == 1
        seq_info.IF     = 335;       % Initial frame for seq45-3p-1111 cam1
        seq_info.x0_1   = 120 ;     % initial x position  
        seq_info.y0_1   = 80 ;      % initial y position  
        seq_info.x0_2   = 289 ;     % initial x position  
        seq_info.y0_2   = 87 ;      % initial y position  
        seq_info.x0_3   = 212 ;     % initial x position  
        seq_info.y0_3   = 100;      % initial y position 
        seq_info.LF     = 500;      % Last frame for seq45-3p-1111 cam1  
        seq_info.dx_1   = 30;       % Initial x scale     
        seq_info.dy_1   = 36;       % Initial y scale     
        seq_info.dx_2   = 20;       % Initial x scale     
        seq_info.dy_2   = 27;       % Initial y scale     
        seq_info.dx_3   = 25;       % Initial x scale     
        seq_info.dy_3   = 41;       % Initial y scale     
        
    elseif cam_number == 2
        seq_info.IF     = 595;       % Initial frame for seq45-3p-1111 cam2
        seq_info.x0_1   = 106 ;     % initial x position  
        seq_info.y0_1   = 83;      % initial y position  
        seq_info.x0_2   = 16 ;     % initial x position  
        seq_info.y0_2   = 95;      % initial y position  
        seq_info.x0_3   = 160 ;     % initial x position 
        seq_info.y0_3   = 90;      % initial y position  
        seq_info.LF     = 750;      % Last frame for seq45-3p-1111 cam2
        seq_info.dx_1   = 20;       % Initial x scale    
        seq_info.dy_1   = 26;       % Initial y scale   
        seq_info.dx_2   = 19;       % Initial x scale   
        seq_info.dy_2   = 27;       % Initial y scale   
        seq_info.dx_3   = 16;       % Initial x scale   
        seq_info.dy_3   = 26;       % Initial y scale   
        
        
    elseif cam_number == 3
        seq_info.IF     = 420;       % Initial frame for seq45-3p-1111 cam3
        seq_info.x0_1   = 247;     % initial x position   
        seq_info.y0_1   = 75 ;      % initial y position 
        seq_info.x0_2   = 149 ;     % initial x position 
        seq_info.y0_2   = 66 ;      % initial y position 
        seq_info.x0_3   = 22 ;     % initial x position 
        seq_info.y0_3   = 70 ;      % initial y position
        seq_info.LF     = 740;      % Last frame for seq45-3p-1111 cam3
        seq_info.dx_1   = 31;       % Initial x scale 
        seq_info.dy_1   = 38;       % Initial y scale 
        seq_info.dx_2   = 20;       % Initial x scale 
        seq_info.dy_2   = 26;       % Initial y scale 
        seq_info.dx_3   = 17;       % Initial x scale 
        seq_info.dy_3   = 22;       % Initial y scale 
        
    end    

end


%% Compute reference histogram

image = read(TrackedMov,seq_info.IF); % Read the initial frame of sequence
image_hsv     = rgb2hsv(image);

for i=1:seq_info.speaker
    
    y_lower = seq_info.(['y0_' num2str(i)]) - round(seq_info.(['dy_' num2str(i)])/2);           % Defining bounds of the box
    y_upper = seq_info.(['y0_' num2str(i)]) + round(seq_info.(['dy_' num2str(i)])/2);           % Defining bounds of the box
    x_lower = seq_info.(['x0_' num2str(i)]) - round(seq_info.(['dx_' num2str(i)])/2);           % Defining bounds of the box
    x_upper = seq_info.(['x0_' num2str(i)]) + round(seq_info.(['dx_' num2str(i)])/2);           % Defining bounds of the box


    if(model.HSV==1)      % Compute Histogram whether HSV or color model
        subimage    = image_hsv( y_lower:y_upper, x_lower:x_upper, : );
        subimage_id    = image_hsv( y_lower:y_upper+30, x_lower:x_upper, : );  % Some part of body is also added
        seq_info.(['RefHist_' num2str(i)])     = hsvHist( subimage , model.bins );
        seq_info.(['RefHist_id_' num2str(i)])     = hsvHist( subimage_id , model.bins );
        
    else
        subimage    = image_hsv( y_lower:y_upper, x_lower:x_upper, : );
        seq_info.(['RefHist_' num2str(i)])     = colorHist( subimage , model.bins );
    end
    
end







