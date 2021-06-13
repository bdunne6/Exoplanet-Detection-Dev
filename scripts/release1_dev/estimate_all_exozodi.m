%% initialzie and set up paths
clear;
close all;
addpath(genpath(fullfile('..','..','src')))

%% settings
mat_root = fullfile('..','mat_files');
output_dir = 'plots';


%set up initial guess for exozodi model
exozodi_init = SimpleExozodi([48 48]);
exozodi_init.intensity_scale = 2000;
exozodi_init.axes_ratio = 0.5;
exozodi_init.orientation = 0;
exozodi_init.center_xy = [23 23];
exozodi_init.exp_scale = 10;
exozodi_init.poly_coeff = [-1 0 0];

%create the output directory if it doesn't exist
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end

%load a sample image to fit to
load(fullfile(mat_root,'release1_data.mat'));

image_set = release1_data.images;
mean_psf = mean(release1_data.cal.psf.data,3);
%exozodi_init.psf = mean_psf;
mask_center = [25,25];

%plot the initial guess
img_init = exozodi_init.get_component();
figure;
imagesc(img_init)
title('exozodi initial guess')

for i1 = 1:numel(image_set)
    img_observed = image_set(i1).data;
    %set up the optimizer
    optimizer = LMOptimizer();
    optim_opts = OptimizerOptions();
    optim_opts.loss_fun_args = {'loss_function','hybrid_log','loss_threshold',1000};
    optimizer.options = optim_opts;
    
    %subtract median background
    img_bgnd = median(img_observed(:));
    img_observed = img_observed - img_bgnd;
    %img_observed = img_observed - 800;
    img_observed = img_observed(10:end-10,10:end-10);
    img_observed_plot = img_observed;
    %apply a mask of nans to the area close to the starshade
    mask_inds = circular_nan_mask(size(img_observed),mask_center,3);
    img_observed(mask_inds) = nan;
    
    %construct and optimize the estimation problem
    exoprob = ExoplanetEstimationProblem(exozodi_init,img_observed,optimizer);
    [exozodi_opt, residual, estimated_image ,i_outlier,cnt] = exoprob.optimize('verbose',1);
    
    %display the observed image, estimated image, and residual
    clims = prctile(img_observed(:),[5 99.9]);
    estimated_image(logical(mask_inds)) = nan;
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    
    %%make plots
    ti1 = tiledlayout(1,3);
    ti1.TileSpacing = 'compact';
    ti1.Padding = 'compact';
    nexttile()
    imagesc(img_observed_plot)
    caxis(clims)
    title('Observed Image','FontSize',16)
    
    clims1 = get(gca,'CLim');
    nexttile()
    imagesc(estimated_image)
    caxis(clims)
    title('Best-fit Disk With Starshade Mask','FontSize',16)
    
    clims = prctile(residual(:),[1 100]);
    nexttile()
    imagesc(residual)
    title('Residual With Starshade mask','FontSize',16)
    caxis(clims)
    drawnow();
    
    [~,fname] = fileparts(image_set(i1).file_path);
    title(ti1,fname,'Interpreter','none','FontSize',20)
    
    disp('mean residual:')
    mean(abs(residual(:)),'omitnan')
    
    outdir_res = fullfile(output_dir,'disk_residual_plots');
    if ~exist(outdir_res,'dir')
        mkdir(outdir_res);
    end
    
    pfilename = fullfile(outdir_res,[fname, '_residual.png']);
    saveas(f1,pfilename);
end

