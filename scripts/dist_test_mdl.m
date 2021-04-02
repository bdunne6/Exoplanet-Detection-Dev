clear;
close all;
addpath(genpath(fullfile('..','src')))

%set up initial guess for exozodi model
exozodi_init = SimpleExozodi([67 67]);
exozodi_init.intensity_scale = 2000;
exozodi_init.axes_ratio = 0.5;
exozodi_init.orientation = pi/4;
exozodi_init.center_xy = [33 33];
exozodi_init.exp_scale = 10;
exozodi_init.poly_coeff = [-1 0 0];

%plot the initial guess
img_init = exozodi_init.get_component();
figure;
imagesc(img_init)
title('exozodi initial guess')

%load a sample image to fit to
load('release1_data.mat');
img_observed = release1_data.images(12).data;


%set up the optimizer
optimizer = LMOptimizer();
optim_opts = OptimizerOptions();
optim_opts.loss_fun_args = {'loss_function','hybrid_log','loss_threshold',10000};
optimizer.options = optim_opts;

%subtract median background
img_observed = img_observed - median(img_observed(:));
%apply a mask of nans to the area close to the starshade
mask_inds = circular_nan_mask(size(img_observed),[34,34],3);
img_observed(mask_inds) = nan;

%construct and optimize the estimation problem
exoprob = ExoplanetEstimationProblem(exozodi_init,img_observed,optimizer);
[image_components_opt, residual, estimated_image ,i_outlier,cnt] = exoprob.optimize('verbose',1);

%display the observed image, estimated image, and residual
estimated_image(logical(mask_inds)) = nan;
figure;
tiledlayout(1,3)
nexttile()
imagesc(img_observed)
nexttile()
imagesc(estimated_image)
nexttile()
imagesc(residual)
disp('mean residual:')
mean(abs(residual(:)),'omitnan')


