close all;
fits_files = dir('X:\project_data\JPL\starshade_exoplanet\release_3_data\1972_SEDC_Spectroscopy_Simulations\Roman\*.fits');
for i1 = 1:numel(fits_files)
    fits_pathi1 = fullfile(fits_files(i1).folder,fits_files(i1).name);
    disp(fits_files(i1).name)
    info_i1 = fitsinfo(fits_pathi1);
    info_i1
    data_i1 = fitsread(fits_pathi1,'raw');
    figure;
    imagesc(data_i1)
    title(fits_files(i1).name,'Interpreter','none')
end
