function dout  = mf_planet_detector(img1,psf,r_range_pixels,n_max)

img_size = size(img1);
img_size = img_size(1:2);
img_c = fliplr(img_size)/2;

rdist_min = r_range_pixels(1);
rdist_max = r_range_pixels(2);

img_mf = conv2(img1,psf,'same');

[cent_xy0,g_ind0,bin_lmax] = detect_local_maxima(img_mf,Inf);

r_dist = vecnorm(cent_xy0 - img_c ,2,2);
i_valid = (r_dist > rdist_min);
cent_xy0 = cent_xy0(i_valid,:);
g_ind0 = g_ind0(i_valid);
r_dist = r_dist(i_valid);

%     [idx,d] = rangesearch(cent_xy,xym,2);
%     i_rm = [idx{:}];
%     i_rm = [];
%     cent_xy(i_rm,:) = [];
%     g_ind(i_rm) = [];
%     r_dist(i_rm) = [];

%i_outlier = isoutlier(g_ind,'gesd');
%i_outlier = isoutlier(g_ind,'median');
[i_outlier, lth, uth, center] = isoutlier(g_ind0,'grubbs');
i_outlier = i_outlier&(g_ind0 > median(g_ind0)); %positive outliers
i_outlier = i_outlier&(r_dist < rdist_max);%enforce max dist

i_outlier = find(i_outlier);
i_outlier = i_outlier(1:min(numel(i_outlier),n_max));

g_ind = g_ind0(i_outlier);
cent_xy = cent_xy0( i_outlier,:);

dout = struct();

detections = struct();
detections.locations = cent_xy;
detections.intensities = g_ind;

candidates = struct();
candidates.locations = cent_xy0;
candidates.intensities = g_ind0;
candidates.i_detected = i_outlier;
candidates.lower_thresh = lth;
candidates.upper_thresh = uth;
candidates.cennter = center;

dout.img_mf = img_mf;
dout.detections = detections;
dout.candidates = candidates;
dout.bin_locmax = bin_lmax;
end