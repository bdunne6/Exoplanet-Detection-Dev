clear; setup_path();
%close all;


mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));


img_set = load(fullfile(mat_output_root,'img_set_disk_1em10_rev2.mat')).img_set;
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
       w=5;

    [cent1,cent_fit1] = refine_centroid_gaussian(res1_0 ,cent0,w,sigma_lookup1);
    cent_uncertainty = diff(cent_fit1.ci(2:3,:),1,2)/2;
    [~,SNR0,noise_mag,noise_per_pixel] = estimate_counts(res1_0,cent1,5);


    
    %dev %%%%%%%%%%%%%%%%%%%%%%%%%
    %PSF_fit = cent_fit1.y_opt - cent_fit1.x_opt(4);

    PSF_fit = sample_gaussian_psf(cent_fit1,7);
    [SNR2] = estimate_SNR(image_m,PSF_fit,noise_per_pixel)


    int_times = image_m.lookup_fits_key('INTTIME');
    int_time1 = int_times{1};
    dark_curr = image_m.lookup_fits_key('DARKCURR');
    dark_curr = dark_curr{1};

    readout_noise = image_m.lookup_fits_key('READOUT');
    readout_noise = readout_noise{1};

    detgain = image_m.lookup_fits_key('DETGAIN');


    nframes = image_m.lookup_fits_key('NFRAMES');
    nframes = nframes{1};

        %counts_snr1
    %PSF_fit = cent_fit1.y_opt - cent_fit1.x_opt(4);
    S_fit = sum(PSF_fit,'all');
    PSF_norm = PSF_fit/sum(PSF_fit(:));
    sharpness = sum(PSF_norm(:).^2);

        eff_readout_noise =   readout_noise*nframes/sqrt(nframes);

        int_time_s = int_time1
    %P_sky_background = noise_mag;
    %B = noise_per_pixel + eff_readout_noise^2;

    S_e = S_fit;

    SNR_num = S_e;
    S_n = (( dark_curr*(int_time_s+46) + noise_per_pixel)/sharpness);
    SNR_denom_sq = S_e + S_n;

    SNR1 = SNR_num/sqrt(SNR_denom_sq);

    sqrt(dt.planets_total_PSF_counts)
    SNR2
    SNR1 
    SNR0
    dt.snr_goal

    figure;
    imagesc(res1_0);
    hold on;
    plot(cent0(1),cent0(2),'.r');

    disp('GT ratios')
    dt.planets_total_PSF_counts/(std(dt.scene_noise_realization(:))/sharpness)

    end
end