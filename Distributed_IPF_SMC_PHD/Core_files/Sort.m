function [speakerx] = Sort(speakerx)
% This function implements proposed 
% The implementation code is written by Peipei Wu
% @ June 2021, University of Surrey

temp = speakerx;
speakerx = []
while size(temp,2)
    [~ , i] = min(temp(1,:));
    speakerx = [speakerx temp(:,i)]
    temp(:,i) = []
end


end

