function [PSF] = sample_gaussian_psf(s,w)
%SAMPLE_GAUSSIAN Summary of this function goes here
%   Detailed explanation goes here
yr = 1:w;
xr = 1:w;

hw0 = (size(s.y_opt,1)-1)/2;
hw1= (w-1)/2;

x_opt = s.x_opt;
x_opt(2:3) = x_opt(2:3) + (hw1-hw0);

[Xg,Yg] = meshgrid(xr,yr);


PSF = gaussian_psf(x_opt,Xg,Yg) - x_opt(4);
end

