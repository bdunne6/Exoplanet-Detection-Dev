setup_path();clear;
close all;


%% user settings %%%%%%%%%%%%%%%%
rdist_min = 3;
rdist_max = 20;
n_planets = 3;

mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));
psf_mat = fullfile('..','mat_files','psf_data.mat');

load(psf_mat,'psf_data');

load(fullfile(mat_output_root,'img_set_disk_1em10_rev4.mat'),'img_set');

img_set = img_set.unstack();

psf1 = psf_data(1).psfs(:,:,end);
psf2 = psf_data(2).psfs(:,:,end);

psf_size = [25,25];
[psf1,crop_inds] = crop_at_position(psf1,round(size(psf1)/2),psf_size);
[psf2,crop_inds] = crop_at_position(psf2,round(size(psf2)/2),psf_size);

psf = cat(3,psf1,psf2);


dt_lookup = containers.Map;

it = ismember({cat(1,cat(1,img_set.images).meta).file_name},dt_lookup.keys);

img_set0 = img_set.copy();
% img_set.images(~it) = [];


pat = 'R05_v2_rez2_snr3';
file_names = {cat(1,cat(1,img_set.images).meta).file_name};
i_match = contains(file_names,pat);
sum(i_match)



img_set.images(~i_match ) = [];

dmax = 0;
for i1 = 1:numel(img_set.images)
    %% load image data %%%
    image_m = img_set.images(i1);

    %% load appropriate PSF
    mlam = image_m.lookup_fits_key('MINLAM');
    mlam = mlam{1};
    if mlam == 425
        psf = psf1;
    else
        psf = psf2;
    end

    %% use the ROI image
    img0 = image_m.data_roi;

    %% subtract previously computed background
    bgnd1 = image_m.meta(1).background_estimate;
    %     sbgnd = img_set.images(i1).meta.disk.exozodi_image;
    %     bgnd2 = crop_at_position(sbgnd,fliplr(size(sbgnd))/2,size(bgnd1));

    imgt = img0 - bgnd1;

    %% do some additional background subtraction with a median filter
    img1 = imgt - medfilt2(imgt,[17,17]);

    %% run matched filtering based planet detector
    pdet = mf_planet_detector(img1,psf,[rdist_min,rdist_max],n_planets);

    %% unpack outputs
    img_mf = pdet.img_mf;
    bin_lmax = pdet.bin_locmax;
    g_ind = pdet.candidates.intensities;
    cent_xy = pdet.detections.locations;


    if isstruct(image_m.meta.planets)&&isfield(image_m.meta.planets,'xy_pixels')
        xym = cat(1,image_m.meta.planets.xy_pixels)-12;
        xm = xym(:,1);
        ym = xym(:,2);
    else
        xm = nan;
        ym = nan;
    end
    xym = [xm,ym];


    %remove detections that are close/redundant with previous detections
    [idx,d] = rangesearch(cent_xy,xym,2);
    i_rm = [idx{:}];
    %i_rm = [];
    cent_xy(i_rm,:) = [];
    g_ind(i_rm) = [];
    %r_dist(i_rm) = [];

    s = 3;
    kg = fspecial('gaussian',round(s*[7 7]),s);
    img_lp = conv2(img1, kg,'same');


    img_c = fliplr(size(img1))/2;


    %     mad = median(abs(img_mf(:) - median(img_mf(:))));
    mad = median(abs(g_ind(:) - median(g_ind(:))));
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
    hold on;
    plot(xm,ym,'or')
    plot(xd,yd,'+r')
    plot(xt,yt,'.r')


    subplot(1,3,3)
    hold off;
    imagesc((img_mf>mad*3)&bin_lmax)
    hold on;
    plot(xm,ym,'or')
    plot(xd,yd,'+r')
    plot(xt,yt,'.r')

    dmax = max([dmax,vecnorm([xt(:),yt(:)]-img_c,2,2)']);

    pause(1.5);
end

