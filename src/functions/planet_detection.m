function [cent_xy,g_ind,bin] = planet_detection(rg,n)
%PLANET_DETECTION Summary of this function goes here
%   Detailed explanation goes here
bin = imregionalmax(rg);
% imagesc(bin)
[rm,cm] = find(bin);
ind = sub2ind(size(rg),rm,cm);
g_ind = rg(ind);

[g_ind,i_s] = sort(g_ind,'descend');

if (nargin == 1)||(n==inf)
    n = numel(i_s);
end

cent_xy = [cm(i_s(1:n)),rm(i_s(1:n))];
end