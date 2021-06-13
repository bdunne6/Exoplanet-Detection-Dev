addpath(genpath(fullfile('..','src')));

load('release1_data.mat')

d1 = release1_data;

figure;
psfs = d1.cal.psf.data;
psf1 = mean(psfs,3);
psf_center = round(size(psf1)/2);

Nc = 51;
Nch = (Nc-1)/2;
r_center = psf_center(1)-Nch : psf_center(1)+Nch;
c_center = psf_center(2)-Nch : psf_center(2)+Nch;
psft = psf1(r_center,c_center);
% imagesc(log(psft))

figure;
tdata = d1.cal.transmission.data;
plot(tdata(1,:),tdata(2,:));

imgs = d1.images;
figure;
t = tiledlayout(5,6);
t.TileSpacing = 'compact';
t.Padding = 'compact';
for i1 = 1:numel(imgs)
    imgi1 = imgs(i1).data;
    %filt_img = imfilter(imgs(i1).data,psf1);
    filt_img = imfilter_norm(imgi1,psft);
    %filt_img = normxcorr2(psft,imgs(i1).data);
    nexttile()
    imagesc(filt_img>0.3)
    %     imagesc(filt_img);
    %     imgi1(imgi1<0) = 0;
    %     imagesc(log(imgi1+1));
    [~,file_name,ext] = fileparts(imgs(i1).file_path);
    title(file_name,'Interpreter','none')
end