function [cent1,fit_data] = refine_centroid_gaussian(img1,cent0,w,sigma_lookup)
%REFINE_CENTROID Summary of this function goes here
%   Detailed explanation goes here

img_c = fliplr(size(img1))/2;
rdist = norm(cent0 - img_c);
sigma = interp1(sigma_lookup.pixel_dist,sigma_lookup.sigma,rdist,'nearest','extrap');
e_ratio = interp1(sigma_lookup.pixel_dist,sigma_lookup.energy_ratio,rdist,'nearest','extrap');

hw = (w-1)/2;
xy_c = round(cent0);
%crop size w-by-w around centroid
rc = xy_c(2)-hw:xy_c(2)+hw;
cc = xy_c(1)-hw:xy_c(1)+hw;
imgc = img1(rc,cc);
fit_data = fit_gaussian_psf(imgc,sigma);

%divide by previously computed ratio for 7x7 gaussian vs actual PSF
est_counts = sum(fit_data.y_opt(:))/e_ratio;
fit_data.counts = est_counts;

cent1 = fit_data.x_opt(2:3);
cent1 = cent1 + [cc(1)-1,rc(1)-1];
end

