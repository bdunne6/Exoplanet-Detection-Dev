%load('release2_data.mat')
fits_file = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3\Calibration files\psf_averaged_NI2_sedc_1em10_0425_0552_nm.fits';

addpath(genpath(fullfile('..','..','src')))


fits_info = fitsinfo(fits_file);
fits_data = fitsread(fits_file);

[vals] = lookup_fits_key(fits_info,'PIXSCALE');

% beta = nlinfit(X,Y,modelfun,beta0);

pixel_scale = 21.85;%mas
ddist = 1;

fits_data = permute(fits_data,[2,3,1]);
% figure;
% for i1 = 1:size(fits_data,3)
%     imagesc(fits_data(:,:,i1))
%     colorbar;
%     title(num2str(i1/pixel_scale))
%     pause(0.1)
% end

plot((1:151)/pixel_scale,squeeze(sum(fits_data,[1,2])))

psf1 = fits_data(:,:,100);

s_psf = size(psf1);
xy_c = round(fliplr(s_psf/2));

hc = 5;
psf1 = psf1(xy_c(2)-hc:xy_c(2)+hc,xy_c(1)-hc:xy_c(1)+hc);

% figure;
% plot(sum(psf1,1))
% hold on;
% plot(sum(psf1,2))

yl = 1:size(psf1,1);
xl = 1:size(psf1,2);

[Xg,Yg] = meshgrid(xl,yl);

xy_c = [mean(xl),mean(yl)];
x0 = [1,xy_c(1),xy_c(2),3];
[y] = gaussian_psf(x0,Xg,Yg);
% 
% model_fun = @(x) (gaussian_psf(x,Xg,Yg));

% figure;
% imagesc(y)

g.Xg = Xg;
g.Yg = Yg;

[x_opt,R,J,covb,mse] = nlinfit(g,psf1(:),@model_fun,x0);
[y_opt] = gaussian_psf(x_opt,Xg,Yg);


function y = model_fun(x,g)
y = gaussian_psf(x,g.Xg,g.Yg);
y = y(:);
end