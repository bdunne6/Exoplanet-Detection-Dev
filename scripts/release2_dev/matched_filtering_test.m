setup_path();clear;

mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));
dest_root = fullfile('..','mat_files');

mat_out = fullfile(dest_root,'psf_data.mat');

load(mat_out,'psf_data');

load(fullfile(mat_output_root,'img_set_disk_1em10_rev2.mat'),'img_set');

% img_set = img_set.unstack();


psf1 = psf_data(1).psfs(:,:,end);
psf2 = psf_data(2).psfs(:,:,end);

psf_size = [25,25];
[psf1,crop_inds] = crop_at_position(psf1,round(size(psf1)/2),psf_size);
[psf2,crop_inds] = crop_at_position(psf2,round(size(psf2)/2),psf_size);

psf = cat(3,psf1,psf2);

for i1 = 1:numel(mat_true)
    mat_filei1 = fullfile(mat_true(i1).folder,mat_true(i1).name);
    dt = load(mat_filei1);

    fits_name = strrep(mat_true(i1).name,'.mat','.fits');

    image_m = img_set.select('equal',struct('file_name',fits_name)).images;
    img0 = image_m.data_roi;

    bgnd1 = cat(3,image_m.meta(1).background_estimate,image_m.meta(2).background_estimate);

    img1 = img0 - bgnd1;

    img_size = size(img1);
    img_size = img_size(1:2);
    img_c = fliplr(img_size)/2;

    xt= dt.planets_approx_position_x_pix + img_c(1);
    yt= dt.planets_approx_position_y_pix + img_c(2);

    %imgf = convn(img1,psf,'same');

    imgf = cat(3,conv2(img1(:,:,1),psf1,'same'),conv2(img1(:,:,2),psf2,'same'));

    imgf1 = imgf(:,:,1);
    imgf2 = imgf(:,:,2);

    

    figure;
    subplot(1,2,1)
    imagesc(imgf1)
    hold on;
    plot(xt,yt,'.r')
    subplot(1,2,2)
    imagesc(imgf2)
        hold on;
    plot(xt,yt,'.r')

end

% function convolve_variable_psf(img1,psf_data)
% img_c = fliplr(size(img1))/2;
% img_c = img_c(1:2);
%
% img1_p =
%
%
% [xg,yg] = meshgrid(1:size(img1,2),1:size(img1,1));
% rdist = sqrt((xg-img_c(1)).^2 + (yg-img_c(2)).^2);
%
% for i1 = 1:size(img_c)
%
% sigma = interp1(sigma_lookup.pixel_dist,sigma_lookup.sigma,rdist,'nearest','extrap');
%
% end