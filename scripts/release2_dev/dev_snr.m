clear; setup_path();
%close all;


mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));


img_set = load(fullfile(mat_output_root,'img_set_disk_1em10_rev5.mat')).img_set;
img_set = img_set.unstack;
%img_set.

for i1 = 1:numel(mat_true)
    mat_filei1 = fullfile(mat_true(i1).folder,mat_true(i1).name);
    dt = load(mat_filei1);

    fits_name = strrep(mat_true(i1).name,'.mat','.fits');

    image_m = img_set.select('equal',struct('file_name',fits_name)).images;

    if isempty(image_m.meta.planet_locations)
        continue;
    end

    for i2 = 1:numel(image_m.meta.planet_locations)
    cargs = image_m.meta.planet_locations(i2).centroid_args;


    %TODO: Fix the SNR calculation using proper PSF SNR estimation math:
    %https://www.stsci.edu/instruments/wfpc2/Wfpc2_hand6/ch6_exposuretime6.html

    [res1_0 ,cent0,w,sigma_lookup1] = cargs{:};
       w=7;

    [cent1,cent_fit1] = refine_centroid_gaussian(res1_0 ,cent0,w,sigma_lookup1);
    cent_uncertainty = diff(cent_fit1.ci(2:3,:),1,2)/2;
    [~,SNR0,noise_mag,noise_per_pixel] = estimate_counts(res1_0,cent1,5);


    
    %dev %%%%%%%%%%%%%%%%%%%%%%%%%
    %PSF_fit = cent_fit1.y_opt - cent_fit1.x_opt(4);

    PSF_fit = sample_gaussian_psf(cent_fit1,7);
    SNR1 = estimate_SNR(image_m,PSF_fit,noise_per_pixel);

    SNR1 
    SNR0
    dt.snr_goal

    figure;
    imagesc(res1_0);
    hold on;
    plot(cent0(1),cent0(2),'.r');

    end
end