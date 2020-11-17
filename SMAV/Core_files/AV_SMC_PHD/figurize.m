% This script detects id of the detected speakers and draws rectangle
% around them.
% @ August 2016, University of Surrey

if ~isempty(hat_X{k})
speaker_id= check_id(hat_X{k},frame.original,model,seq_info);
end

d   =   0;
for j=1:seq_info.speaker
    d   =  d + [ seq_info.(['dx_' num2str(j)]) seq_info.(['dy_' num2str(j)]) ];
end 
d   =   d / seq_info.speaker;

for j=1:hat_N(k)
 
    if speaker_id(j)>seq_info.speaker        
        [ frame.(['av_smcphd' num2str(FrameNumber)]),hat_X_marker{k,j}(:,:)  ]=...
        drawRectangle(frame.(['av_smcphd' num2str(FrameNumber)]),...
        [hat_X{k}(1,j) hat_X{k}(3,j)],hat_X{k}(5,j), round( d/2),4);  %#ok<SAGROW>
    else
        [ frame.(['av_smcphd' num2str(FrameNumber)]),hat_X_marker{k,j}(:,:)  ]=...
        drawRectangle(frame.(['av_smcphd' num2str(FrameNumber)]),...
        [hat_X{k}(1,j) hat_X{k}(3,j)] ,hat_X{k}(5,j), round( d/2),speaker_id(j));%#ok<SAGROW> %, fid);  % Draw Rectangle 
    end 
end

%*************************************************************************%
%                        Plot k.th Frame
%*************************************************************************%
% If the speaker is detected, rectangle will be drawn at above,
% Here, image will be printed either with rectangle or without rectangle
if flag.print_frame    
    clf   % it is necessary to prevent slowing down
    font_label  = 10; 
        
    imshow( frame.(['av_smcphd' num2str(FrameNumber)]) );   
    title('PF-AV-SMC-PHD','FontSize',10,'FontWeight','normal');
    xlabel(['Frame = ', num2str(FrameNumber) ] )
    hold on;
    drawnow;
end

if flag.save_frame
 saveas(gcf, [resultsPath  num2str(k) '.png'] );
end
