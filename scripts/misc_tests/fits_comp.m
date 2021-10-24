
data_root = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3\';

img_fits = fullfile(data_root,'Simulated data\sister_sedc_starshade_rendezvous_imaging_1em9\sister_R01_v1_rez1_snr1_0425_0552_nm_r2_1em9.fits');
psf_fits = fullfile(data_root,'Calibration files\psf_averaged_NI2_sedc_1em9_0425_0552_nm.fits');
trans_fits = fullfile(data_root,'Calibration files\starshade_averaged_transmission_NI2_sedc_1em9_0425_0552_nm.fits');

sister_gen = 'C:\Users\bdunne\source\repos\JPL\sister_v1.1\output\image_data\sister_run_scene_3_Formalhaut_B_solar_glint.fits';


img_fits_info = fitsinfo(img_fits);
psf_fits_info = fitsinfo(psf_fits);
trans_fits_info = fitsinfo(trans_fits);
sister_fits_info = fitsinfo(sister_gen);




 challenge_img = fitsread(img_fits,'Raw');
sister_img = fitsread(sister_gen,'Raw');

figure;
imagesc(challenge_img)
figure;
imagesc(sister_img)