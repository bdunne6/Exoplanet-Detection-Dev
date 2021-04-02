cal_root = 'X:\project_data\JPL\starshade_exoplanet\1860_Release_1\Calibration data\';

psf_file = fullfile(cal_root,'psf_averaged_0425_0552_nm.fits');

info = fitsinfo(psf_file);
psf = fitsread(psf_file,'raw');

% for i1 = 1:size(psf,1)
%     figure(101)
%     imagesc(squeeze(psf(i1,:,:)))
%     pause(1)
% end

data_root = 'X:\project_data\JPL\starshade_exoplanet\1860_Release_1\Simulated data';

image_files = dir(fullfile(data_root,'*.fits'));
psf1 = squeeze(psf(1,:,:));
for i1 = 1:numel(image_files)
    image_filei1 = fullfile(image_files(i1).folder,image_files(i1).name);
    info = fitsinfo(image_filei1);
    imgi1 = fitsread(image_filei1,'raw');
    
    figure;
    subplot(2,1,1)
    imagesc(imgi1 )
    subplot(2,1,2)
    img_conv = conv2(imgi1,psf1./sum(psf1(:)),'same');
    imagesc(img_conv)
    
    figure;
    imagesc(imgi1-img_conv)
    
    [Gmag, Gdir] = imgradient(imgi1,'prewitt');
end
