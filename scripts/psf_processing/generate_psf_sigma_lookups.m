%load('release2_data.mat')
data_root = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3\Calibration files\';
dest_root = fullfile('..','mat_files');

psf_files = dir(fullfile(data_root,'psf_*.fits'));

%fits_file = 'psf_averaged_NI2_sedc_1em10_0425_0552_nm.fits';

addpath(genpath(fullfile('..','..','src')))

%% script settings
psf_crop = 11;


%% main script

figure;
for i0 = 1:numel(psf_files)
    fits_file = fullfile(psf_files(i0).folder,psf_files(i0).name);
    fits_info = fitsinfo(fits_file);
    psfs = fitsread(fits_file);

    pixscale = lookup_fits_key(fits_info,'pixscale');
    ddist  = lookup_fits_key(fits_info,'ddist');

    psfs = permute(psfs,[2,3,1]);

    pixel_dist = nan(size(psfs,3),1);
    sigma = nan(size(psfs,3),1);
    transmission = nan(size(psfs,3),1);

    for i1 = 1:size(psfs,3)
        psf_i1 = psfs(:,:,i1);
        s_psf = size(psf_i1);
        xy_c = round(fliplr(s_psf/2));
        hc = (psf_crop-1)/2;
        psf_i1 = psf_i1(xy_c(2)-hc:xy_c(2)+hc,xy_c(1)-hc:xy_c(1)+hc);
        fit_data = fit_gaussian_psf(psf_i1);

        pixel_dist(i1) = i1*ddist/pixscale;
        sigma(i1) = fit_data.x_opt(4);
        transmission(i1) = sum(psfs(:,:,i1),'all');
    end


    [~,fname] = fileparts(psf_files(i0).name);
    fname = [fname,'_sigma_lookup.mat'];
    dest_file = fullfile(dest_root,fname);
    save(dest_file,'pixel_dist','sigma');

    hold on;
    plot(pixel_dist,sigma);
    ylim([0 Inf])
    drawnow();
end
legend({psf_files.name},'Interpreter','none');
%
% figure;
% imagesc(fit_data.y_opt);
