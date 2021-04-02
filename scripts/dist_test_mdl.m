clear;
close all;
addpath(genpath(fullfile('..','src')))


exo1 = SimpleExozodi([67 67]);
exo1.intensity_scale = 2000;
exo1.axes_ratio = 0.5;
exo1.orientation = pi/4;
exo1.center_xy = [33 33];
exo1.exp_scale = 10;
exo1.poly_coeff = [-1 0 0];

img1 = exo1.get_component();

figure;
imagesc(img1)
%p = [2000 0.5 1.0 pi/4 ,33,33, 10 0 0 0 0 0 0 0 0];



p = exo1.vectorize_params();
p(1) = 1025;
exo1t = exo1.devectorize_params(p);  



exo_m = [exo1,exo1t];

exo_mt = exo_m.devectorize_params(exo_m.vectorize_params());


mas_per_pixel = 21.85;
load('release1_data.mat');
d1 = release1_data;
tdata = d1.cal.transmission.data;
img1 = d1.images(12).data;

optim = LMOptimizer();
opts = OptimizerOptions();
opts.loss_fun_args = {'loss_function','hybrid_log','loss_threshold',10000};
optim.options = opts;

img1 = img1 - median(img1(:));
% img1 = imrotate(img1,45,'crop');
% img1(33,33) = nan;
exoprob = ExoplanetEstimationProblem(exo1,img1,optim);
tic
[image_components_opt, residual, estimated_image ,i_outlier,cnt] = exoprob.optimize('verbose',1);
toc

img1(34,34) = nan;
img_mask = zeros(size(img1));
img_mask(34,34) = 1;
dm1 = fspecial('disk',3);
dm1 = dm1./max(dm1(:));
img_mask = conv2(img_mask,dm1,'same')>0.3;
img1(logical(img_mask)) = nan;

exoprob = ExoplanetEstimationProblem(image_components_opt,img1,optim);
tic
[image_components_opt, residual, estimated_image ,i_outlier,cnt] = exoprob.optimize('verbose',1);
toc

image_components_opt

estimated_image(logical(img_mask)) = nan;

figure;
tiledlayout(1,3)
nexttile()
imagesc(img1)
nexttile()
imagesc(estimated_image)
nexttile()
imagesc(residual)

disp('mean residual:')
mean(abs(residual(:)),'omitnan')


