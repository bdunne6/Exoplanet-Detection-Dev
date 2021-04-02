function [corr_map] = imfilter_norm(img1,k1)
%IMFILTER_NORM Summary of this function goes here
%   Detailed explanation goes here
corr_map = normxcorr2(k1,img1);
%resize the correlation map back to image size
kernel_size = size(k1);
rp = floor(kernel_size(1)/2)-1;
cp = floor(kernel_size(2)/2)-1;
corr_map = corr_map(rp:rp+size(img1,1)-1,cp:cp+size(img1,2)-1);
end

