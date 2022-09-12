function [SNR1,SNR_meta] = estimate_SNR(image_m,PSF_fit,noise_per_pixel)
%estimate_SNR estimate SNR using generalized model
%
% implementation of equation 6.6 from here:
%https://www.stsci.edu/instruments/wfpc2/Wfpc2_hand6/ch6_exposuretime6.html




dark_curr = image_m.lookup_fits_key('DARKCURR');
dark_curr = dark_curr{1};
int_times = image_m.lookup_fits_key('INTTIME');
int_time_s = int_times{1};


%counts_snr1
% PSF_fit = cent_fit1.y_opt - cent_fit1.x_opt(4);


S_object = sum(PSF_fit,'all');
PSF_norm = PSF_fit/sum(PSF_fit(:));
sharpness = sum(PSF_norm(:).^2);

SNR_numerator = S_object;
N_object = (noise_per_pixel^2/sharpness);
SNR_denom_sq = S_object + N_object;

SNR1 = SNR_numerator/sqrt(SNR_denom_sq);

SNR_meta = struct();
SNR_meta.S_object = S_object;
SNR_meta.N_object = N_object;
SNR_meta.noise_per_pixel = noise_per_pixel;
% SNR_meta.sharpness = sharpness;
end

