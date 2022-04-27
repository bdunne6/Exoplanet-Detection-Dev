function [img_crop,crop_inds ] = crop_at_position(img,crop_center,crop_size)
%CROP_FROM_CENTER Summary of this function goes here
%   Detailed explanation goes here


xmin = round(crop_center(1) - crop_size(1)/2);
xmax = xmin+crop_size(1)-1;
ymin = round(crop_center(2) - crop_size(2)/2);
ymax = ymin+crop_size(2)-1;
crop_inds = [xmin,xmax,ymin,ymax];


img_crop = img(ymin:ymax,xmin:xmax);
end

