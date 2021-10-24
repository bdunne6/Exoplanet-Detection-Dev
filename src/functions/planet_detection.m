function [cent_xy,g_ind] = planet_detection(rg,n)
%PLANET_DETECTION Summary of this function goes here
%   Detailed explanation goes here
bin = imregionalmax(rg);
% imagesc(bin)
[rm,cm] = find(bin);
ind = sub2ind(size(rg),rm,cm);
g_ind = rg(ind);

[g_ind,i_s] = sort(g_ind,'descend');
cent_xy = [cm(i_s(1:n)),rm(i_s(1:n))];
end

