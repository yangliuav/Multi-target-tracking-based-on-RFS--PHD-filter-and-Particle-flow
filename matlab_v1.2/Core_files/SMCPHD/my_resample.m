function resample_idx= my_resample(w,L)
% This function resamples the particles.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% w         -   the weights with sum(w)= 1.
% L         -   no. of samples you want to resample.
% =========================================================================
% Output:
% resample_idx  - indices for the resampled particles.
% =========================================================================


resample_idx        = [];
[~,sort_idx]  = sort(-w);   %sort in descending order
rv                  = rand(L,1);
i                   = 0;
threshold           = 0;
while ~isempty(rv) && i<size(sort_idx,1)
    i           = i+1; 
    threshold   = threshold+ w(sort_idx(i));
    rv_len      = length(rv);
    idx         = find(rv>threshold); 
    resample_idx= [ resample_idx; sort_idx(i)*ones(rv_len-length(idx),1) ];
    rv          = rv(idx);
end

if ~size(resample_idx,1) % If it is empty
   resample_idx= (1:length(w))';
end

if size(resample_idx,1)<L
    resample_idx = [resample_idx ; repmat(resample_idx,ceil(L/size(resample_idx,1)-1),1)];
    
end
resample_idx = resample_idx(1:L);