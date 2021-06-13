addpath(genpath(fullfile('..','..','src')))

img_folder = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';
fits_files = dir(fullfile(image_folderi0,'*.fits'));
for i1 = 1:numel(fits_files)
    sample_inputi1 = fullfile(fits_files(i1).folder,fits_files(i1).name);
    simg(i1) = StarshadeImage(sample_input);
end
