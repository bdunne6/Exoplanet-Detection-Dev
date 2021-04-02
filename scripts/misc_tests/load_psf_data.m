data_root = 'X:\project_data\JPL\starshade_exoplanet\1860_Release_1\Calibration data\';

psf_file = fullfile(data_root,'psf_averaged_0425_0552_nm.fits');

info = fitsinfo(psf_file);
imgi1 = fitsread(psf_file,'raw');

for i1 = 1:size(imgi1,3)
    figure(101)
    imagesc(squeeze(imgi1(i1,:,:)))
    pause(0.2)
end