data_root = 'X:\project_data\JPL\starshade_exoplanet\1860_Release_1\Simulated data';

image_files = dir(fullfile(data_root,'*.fits'));

for i1 = 1:numel(image_files)
    image_filei1 = fullfile(image_files(i1).folder,image_files(i1).name);
    info        = fitsinfo(image_filei1);
    imgi1 = fitsread(image_filei1,'raw');
end


