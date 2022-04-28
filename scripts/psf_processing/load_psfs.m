clear;
data_root = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3\Calibration files\';
dest_root = fullfile('..','mat_files');

psf_files = dir(fullfile(data_root,'psf_*.fits'));

%% script settings
psf_crop = 7;

psf_data = struct();
for i1 = 1:numel(psf_files)
    fits_file = fullfile(psf_files(i1).folder,psf_files(i1).name);
    fits_info = fitsinfo(fits_file);
    psfs = fitsread(fits_file);

    pixscale = lookup_fits_key(fits_info,'pixscale');
    ddist  = lookup_fits_key(fits_info,'ddist');

    psfs = permute(psfs,[2,3,1]);
    pixel_dist = (1:size(psfs,3))*ddist/pixscale;
    
    [~,fname] = fileparts(psf_files(i1).name);

    psf_data(i1).file_path = fits_file;
    psf_data(i1).file_name = fname;
    psf_data(i1).fits_info = fits_info;
    psf_data(i1).pixel_dist = pixel_dist;
    psf_data(i1).psfs = psfs;
  

end
mat_out = fullfile(dest_root,'psf_data.mat');
save(mat_out,'psf_data');