load('snr_est_inputs.mat');
for i2 = 1:numel(labels_1)
    cent0 = [labels_1(i2).x,labels_1(i2).y];
    w=7;
    %TODO: Fix the SNR calculation using proper PSF SNR estimation math:
    %https://www.stsci.edu/instruments/wfpc2/Wfpc2_hand6/ch6_exposuretime6.html
    [cent1,cent_fit1] = refine_centroid_gaussian(res1_0 ,cent0,w,sigma_lookup1);
    cent_uncertainty = diff(cent_fit1.ci(2:3,:),1,2)/2;
    labels_1(i2).x_r = cent1(1);
    labels_1(i2).y_r = cent1(2);
    labels_1(i2).x_u = cent_uncertainty(1);
    labels_1(i2).y_u = cent_uncertainty(2);
    labels_1(i2).counts = cent_fit1.counts;
    [~,~,noise_mag,noise_per_pixel] = estimate_counts(res1_0,cent1,5);
    labels_1(i2).counts_snr = labels_1(i2).counts/noise_mag;

    %dev %%%%%%%%%%%%%%%%%%%%%%%%%



    int_times = img_set.images(i0).lookup_fits_key('INTTIME');
    int_time1 = int_times{1};
    dark_curr = img_set.images(i0).lookup_fits_key('DARKCURR');
    dark_curr = dark_curr{1};

    readout_noise = img_set.images(i0).lookup_fits_key('READOUT');
    readout_noise = readout_noise{1};

    detgain = img_set.images(i0).lookup_fits_key('DETGAIN');
    detgain = detgain{1};

    nframes = img_set.images(i0).lookup_fits_key('NFRAMES');
    nframes = nframes{1};

        %counts_snr1
    PSF_fit = cent_fit1.y_opt - cent_fit1.x_opt(4);
    S_fit = sum(PSF_fit,'all');
    PSF_norm = PSF_fit/sum(PSF_fit(:));
    sharpness = sum(PSF_norm(:).^2);

    noise_per_pixel = noise_per_pixel*detgain;

        eff_readout_noise =   readout_noise*nframes/sqrt(nframes);

        int_time_s = int_time1
    %P_sky_background = noise_mag;
    B = noise_per_pixel + eff_readout_noise^2;

    S_e = S_fit*detgain

    SNR_num = S_e;
    SNR_denom_sq = S_e + ((eff_readout_noise^2 +dark_curr*(int_time_s+46) + noise_per_pixel)/sharpness);

    SNR1 = SNR_num/sqrt(SNR_denom_sq);

end