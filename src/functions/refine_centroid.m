function [cent1] = refine_centroid(img1,cent0,w)
%REFINE_CENTROID Summary of this function goes here
%   Detailed explanation goes here
    w_lin = -(w-1)/2:(w-1)/2;
    im_s = size(img1);
    [xg,yg] = meshgrid(1:im_s(2),1:im_s(1));

    [cgx,cgy] = meshgrid(cent0(1) + w_lin,cent0(2) + w_lin);
    img_loc = interp2(xg,yg,img1,cgx,cgy);
    img_loc = img_loc - min(img_loc(:));
    cent1 = weighted_centroid(img_loc,cgy(:,1),cgx(1,:));
end

