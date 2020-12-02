% This function is used for reading vision detection result from txt file
% the format of vision dection result is in below format
% [frameID class Cx Cy w h] C means centroid

function strRES = VisionDetect(path)

fVDECT = fopen(path);
strRES = textscan(fVDECT,'%d %d %f %f %f %f');
return;