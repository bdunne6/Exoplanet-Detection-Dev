setup_path();clear;
close all;


%% user settings %%%%%%%%%%%%%%%%
rdist_min = 3;
rdist_max = 20;
n_planets = 3;

mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));
dest_root = fullfile('..','mat_files');

mat_out = fullfile(dest_root,'psf_data.mat');

load(mat_out,'psf_data');

load(fullfile(mat_output_root,'img_set_disk_1em10_rev2.mat'),'img_set');

img_set = img_set.unstack();


psf1 = psf_data(1).psfs(:,:,end);
psf2 = psf_data(2).psfs(:,:,end);

psf_size = [25,25];
[psf1,crop_inds] = crop_at_position(psf1,round(size(psf1)/2),psf_size);
[psf2,crop_inds] = crop_at_position(psf2,round(size(psf2)/2),psf_size);

psf = cat(3,psf1,psf2);


dt_lookup = containers.Map;

for i1 = 1:numel(mat_true)
    mat_filei1 = fullfile(mat_true(i1).folder,mat_true(i1).name);
    dt = load(mat_filei1);

    fits_name = strrep(mat_true(i1).name,'.mat','.fits');

    [image_set_m,is] = img_set.select('equal',struct('file_name',fits_name));

    file_name = img_set.images(is).meta.file_name;
    dt_lookup(file_name) = dt;
    image_m = image_set_m.images;

    mlam = image_m.lookup_fits_key('MINLAM');
    mlam = mlam{1};
    if mlam == 425
        psf = psf1;
    else
        psf = psf2;
    end

    img0 = image_m.data_roi;

    %     bgnd1 = cat(3,image_m.meta(1).background_estimate,image_m.meta(2).background_estimate);
    bgnd1 = image_m.meta(1).background_estimate;

    img1 = img0 - bgnd1;
    %img1 = img0;

    img_size = size(img1);
    img_size = img_size(1:2);
    img_c = fliplr(img_size)/2;


    %imgf = convn(img1,psf,'same');

    image_m.get_fits_keywords
    img_mf = conv2(img1,psf,'same');

    %     img_lp = medfilt2(img1,[9 9]);
    %     img_lp = medfilt2(img1,[9 9]);
    %
    %     img_lp = imbilatfilt(img1,1000);

    s = 3;
    kg = fspecial('gaussian',round(s*[7 7]),s);
    img_lp = conv2(img1, kg,'same');

    imgpt = dt.scene_noiseless_all_components - dt.scene_noiseless_all_components_but_planets;
    roi = image_m.roi;
    rows = roi(2):roi(2)+roi(4)-1;
    cols = roi(1):roi(1)+roi(3)-1;
    imgpt = imgpt(rows,cols,:);

    img_c = fliplr(size(imgpt))/2;

    xt= dt.planets_approx_position_x_pix + img_c(1)+0.5;
    yt= dt.planets_approx_position_y_pix + img_c(2)+0.5;

    if isstruct(image_m.meta.planets)&&isfield(image_m.meta.planets,'xy_pixels')
        xym = cat(1,image_m.meta.planets.xy_pixels)-12;
        xm = xym(:,1);
        ym = xym(:,2);
    else
        xm = nan;
        ym = nan;
    end


    dt.exozodi_inclination_deg


    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1,3,1)
    imagesc(imgpt)
    hold on;
    plot(xt,yt,'.r')
    plot(xm,ym,'or')

    subplot(1,3,2)
    imagesc(img1)
    hold on;
    plot(xt,yt,'.r')
    plot(xm,ym,'or')

    subplot(1,3,3)
    imagesc(img_mf)
    % imagesc(img_lp)
    hold on;
    plot(xt,yt,'.r')
    plot(xm,ym,'or')



    %     figure;
    %     subplot(1,2,1)
    %     imagesc(imgf1)
    %     hold on;
    %     plot(xt,yt,'.r')
    %     subplot(1,2,2)
    %     imagesc(imgf2)
    %         hold on;
    %     plot(xt,yt,'.r')

end




it = ismember({cat(1,cat(1,img_set.images).meta).file_name},dt_lookup.keys);

img_set0 = img_set.copy();
%img_set.images(~it) = [];
dmax = 0;
for i1 = 1:numel(img_set.images)

    image_m = img_set.images(i1);

    mlam = image_m.lookup_fits_key('MINLAM');
    mlam = mlam{1};
    if mlam == 425
        psf = psf1;
    else
        psf = psf2;
    end

    img0 = image_m.data_roi;

    %     bgnd1 = cat(3,image_m.meta(1).background_estimate,image_m.meta(2).background_estimate);
    bgnd1 = image_m.meta(1).background_estimate;
    sbgnd = img_set.images(i1).meta.disk.exozodi_image;
    bgnd2 = crop_at_position(sbgnd,fliplr(size(sbgnd))/2,size(bgnd1));

    imgt = img0 - bgnd1;

    img1 = imgt - medfilt2(imgt,[21,21]);
    %img1 = img1;



    %     figure;
    %     imagesc(bgnd2)

    %img1 = img0;

    img_size = size(img1);
    img_size = img_size(1:2);
    img_c = fliplr(img_size)/2;


    %imgf = convn(img1,psf,'same');

    image_m.get_fits_keywords
    img_mf = conv2(img1,psf,'same');


    if isstruct(image_m.meta.planets)&&isfield(image_m.meta.planets,'xy_pixels')
        xym = cat(1,image_m.meta.planets.xy_pixels)-12;
        xm = xym(:,1);
        ym = xym(:,2);
    else
        xm = nan;
        ym = nan;
    end
    xym = [xm,ym];

    [cent_xy,g_ind] = planet_detection(img_mf,Inf);



    r_dist = vecnorm(cent_xy - img_c ,2,2);
    i_valid = (r_dist > rdist_min);
    cent_xy = cent_xy(i_valid,:);
    g_ind = g_ind(i_valid);
    r_dist = r_dist(i_valid);

    [idx,d] = rangesearch(cent_xy,xym,2);
    i_rm = [idx{:}];
    i_rm = [];
    cent_xy(i_rm,:) = [];
    g_ind(i_rm) = [];
    r_dist(i_rm) = [];

    %i_outlier = isoutlier(g_ind,'gesd');
    %i_outlier = isoutlier(g_ind,'median');
    i_outlier = isoutlier(g_ind,'grubbs');
    i_outlier = i_outlier&(g_ind > median(g_ind)); %positive outliers
    i_outlier = i_outlier&(r_dist < rdist_max);%enforce max dist

    i_outlier = find(i_outlier);
    i_outlier = i_outlier(1:min(numel(i_outlier),n_planets));

    g_ind_np = g_ind(i_outlier);

    figure(103);
    hold off;
    histogram(g_ind)
    hold on;
    if ~isempty(g_ind_np)
        plot(g_ind_np,0,'.','MarkerSize',15);
    end

    %     cent_xy = cent_xy(1:n_planets,:);
    cent_xy = cent_xy( i_outlier,:);


    %     img_lp = medfilt2(img1,[9 9]);
    %     img_lp = medfilt2(img1,[9 9]);
    %
    %     img_lp = imbilatfilt(img1,1000);

    s = 3;
    kg = fspecial('gaussian',round(s*[7 7]),s);
    img_lp = conv2(img1, kg,'same');


    img_c = fliplr(size(imgpt))/2;


    mad = median(abs(img_mf(:) - median(img_mf(:))));
    th = mad*8;


    xd = cent_xy(:,1);
    yd = cent_xy(:,2);


    if dt_lookup.isKey(image_m.meta.file_name)
        dt = dt_lookup(image_m.meta.file_name);
        xt= dt.planets_approx_position_x_pix + img_c(1)+0.5;
        yt= dt.planets_approx_position_y_pix + img_c(2)+0.5;
    else
        xt = nan; yt = nan;
    end

    dt.exozodi_inclination_deg

    figure(101);
    set(gcf,'units','normalized','outerposition',[0 0 1 1])

    subplot(1,3,1)
    hold off;
    imagesc(img1)
    hold on;
    plot(xm,ym,'or')
    plot(xd,yd,'+r')
    plot(xt,yt,'.r')

    subplot(1,3,2)
    hold off;
    imagesc(img_mf)
    % imagesc(img_lp)
    hold on;
    plot(xm,ym,'or')
    plot(xd,yd,'+r')
    plot(xt,yt,'.r')



    subplot(1,3,3)
    hold off;
    imagesc((img_mf>th)+(img_mf>mad*4))
    % imagesc(img_lp)
    hold on;
    plot(xm,ym,'or')
    plot(xd,yd,'+r')
    plot(xt,yt,'.r')


    dmax = max([dmax,vecnorm([xt(:),yt(:)]-img_c,2,2)']);
    %         figure(102);
    %     set(gcf,'units','normalized','outerposition',[0 0 1 1])
    %         subplot(1,3,1)
    %     hold off;
    %     imagesc(img0);
    %
    %             subplot(1,3,2)
    %     hold off;
    %     imagesc(bgnd2);
    %
    %                 subplot(1,3,3)
    %     hold off;
    %     imagesc(img0- bgnd2);

    %     figure;
    %     subplot(1,2,1)
    %     imagesc(imgf1)
    %     hold on;
    %     plot(xt,yt,'.r')
    %     subplot(1,2,2)
    %     imagesc(imgf2)
    %         hold on;
    %     plot(xt,yt,'.r')
    pause(1.5);
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