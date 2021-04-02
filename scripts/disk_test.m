addpath(genpath(fullfile('..','src')))

mas_per_pixel = 21.85;
load('release1_data.mat');
d1 = release1_data;
tdata = d1.cal.transmission.data;


%% TODO: need to add star + exozodi like in SISTER, then convolve with PSF. Then multiply by transmittance? That sounds more like the forward model.
%figure out why the supressed pattern at the center doesn't match, i.e.
%light is much dimmer at center for the generate_disk() function. Is that
%simply because the star is not modelled, or also that the exozodi light
%should be decaying much faster?

nx = 67;
ny = 67;
[Xg,Yg] = meshgrid(1:nx,1:ny);

[ny,nx] = size(Xg);
xc = (nx-1)/2;
yc = (ny-1)/2;
Xgc = Xg - xc;
Ygc = Yg - yc;
r_mas = mas_per_pixel*sqrt(Xgc.^2 + Ygc.^2);

trans_sim = interp1(tdata(1,:),tdata(2,:),r_mas);
trans_sim(isnan(trans_sim)) = 1;

p = [2000 0.5 1.0 pi/4 ,33,33, 10 0 0 0 0 0 0 0 0];
[disk] = generate_disk(p,Xg,Yg,trans_sim);
figure;
imagesc(disk)

img1 = d1.images(1).data;
figure;
imagesc(img1);

min_opts = optimset('fminsearch');

% min_opts.Display = 'iter';
min_opts.MaxFunEvals = 10000;
min_opts.MaxIter = 10000;
min_opts.TolFun = 1e-11;
min_opts.TolX = 1e-11;

p = [1226.609144446953   0.230877199755   0.320339800158   0.035578507403 ,33,33, 10, 0, -1, 0];
for i1 = 12%numel(d1.images)
img1 = d1.images(i1).data;
img1 = img1 - median(img1(:));

img1 = imrotate(img1,45,'crop');


cost_fun = @(x) (sum(abs(img1 - generate_disk(x,Xg,Yg,trans_sim)),'all'));
tic
p_opt = fminsearch(cost_fun,p,min_opts);
toc

tic
disk_opt = generate_disk(p_opt,Xg,Yg,trans_sim);
toc
figure;
subplot(1,3,1)
imagesc(img1)
subplot(1,3,2)
imagesc(disk_opt)
subplot(1,3,3)
imagesc(disk_opt-img1)
end


% figure;
% imagesc(trans_sim)
%
% disk = disk.*trans_sim;
% figure;
% imagesc(disk)
%
% img1 = d1.images(1).data;
% figure;
% subplot(2,1,1)
% imagesc(img1);
% subplot(2,1,2)
% imagesc(trans_sim);
%
% [disk] = generate_disk(p,Xg,Yg,trans_sim)