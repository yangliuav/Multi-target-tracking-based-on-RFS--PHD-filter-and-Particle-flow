function cHist = hsvHist( img, bins )
% This function calculates the histogram of the given image using hue and 
% saturation information.

% =========================================================================
% Input:
% img   -   image input.
% bins  -   number of bins.
% =========================================================================
% Output:
% cHist -   Histogram of the image, bins x bins matrice.
% =========================================================================

   %Determine the size of the image histogram to calculate...
   [rows, columns, ~] = size(img);
   total = rows*columns;
   cHist = zeros(bins,bins); 
   imgBin = ceil( img*bins );
   imgBin(imgBin == 0) = 1;
                         
   %Go through each pixel and bin it
   for i = 1:rows
        for j = 1:columns
           hue =   imgBin(i,j,1); %Hue
           saturation = imgBin(i,j,2); %Saturation
           cHist(hue, saturation) = cHist(hue, saturation) + 1;
        end
   end
   
   %Normalize the histogram:
   cHist = cHist/total; 

end