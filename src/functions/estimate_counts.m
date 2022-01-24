function [est_counts,SNR] = estimate_counts(img1,cent0,w)
%REFINE_CENTROID Summary of this function goes here
%   Detailed explanation goes here
    w_lin = -(w-1)/2:(w-1)/2;
    im_s = size(img1);
    [xg,yg] = meshgrid(1:im_s(2),1:im_s(1));

    [cgx,cgy] = meshgrid(cent0(1) + w_lin,cent0(2) + w_lin);
    img_loc = interp2(xg,yg,img1,cgx,cgy);
    
%     boundary_pix = [img_loc(1:w,1);img_loc(1:w,end);img_loc(1,2:end-1)';img_loc(end,2:end-1)'];
    boundary_pix = img_loc;
    boundary_pix(2:end-1,2:end-1) = NaN;

    interior_pix = img_loc;
    interior_pix(~isnan(boundary_pix)) = NaN;

    local_baseline = median( boundary_pix(:),'omitnan');
    interior_pix = interior_pix - local_baseline;
    est_counts = sum(interior_pix(:),'omitnan');

    %% SNR calc
    noise_per_pixel = std(boundary_pix(:),'omitnan');
    total_signal = est_counts;

    %sum of N pixels noise will give sqrt(N) the noise of one pixel assuming independent
    %normal distributions
    noise_est =  noise_per_pixel*sqrt(sum(~isnan(boundary_pix),'all'));
    SNR = est_counts/noise_est;
end

