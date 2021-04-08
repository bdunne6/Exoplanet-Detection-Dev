function [img_mask] = circular_nan_mask(img_size,center_xy,radius)
%CIRCULAR_NAN_MASK Summary of this function goes here
%   Detailed explanation goes here
img_mask = zeros(img_size);
img_mask(center_xy(2),center_xy(1)) = 1;
dm1 = fspecial('disk',radius);
dm1 = dm1./max(dm1(:));
img_mask = conv2(img_mask,dm1,'same')>0.3;
end

