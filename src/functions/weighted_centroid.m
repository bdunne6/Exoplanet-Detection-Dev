function [centroid] = weighted_centroid(img,r,c)
centroid(2) = sum(sum(img,2).*(r(:)))/sum(img(:));
centroid(1) = sum(sum(img,1).*(c(:)'))/sum(img(:));
end