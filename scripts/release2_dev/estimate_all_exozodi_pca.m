addpath(genpath(fullfile('..','..','src')))

img_folder = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';

% img_set = StarshadeImageSet(img_folder,1);
% save('img_set.mat','img_set');

load('img_set.mat');


% s_select = struct('snr_level',3,'exozodi_intensity',2);
% s_select = struct('snr_level',3);
s_select = struct();
[img_set, i_equal] = img_set.select('equal',s_select);
img_set_new = img_set.stack_by({'passband'});

X = zeros(numel(img_set_new.images),numel(img_set_new.images(1).data));

img_size = size(img_set_new.images(1).data);
for i1 = 1:numel(img_set_new.images)
    X(i1,:) = img_set_new.images(i1).data(:);
end

mdl = pca_model(X,0,1);



figure;
img_mean = reshape(mdl.Xm,img_size);
imagesc(img_mean(:,:,2))


% hs = [0,1.0; %red saturated
%     0.4 1.0]; %green saturated
% figure(110);
% for i1 = 1:numel(img_set_new.images)
%     ms_img1 = img_set_new.images(i1).data;
%     %ms_img1(:,:,2) = 0;
%     rgb1 = multi_spectral_to_rgb(ms_img1,hs,[min(ms_img1(:)), max(ms_img1(:))]);
%
%     imagesc(rgb1)
%     drawnow();
%     pause(1)
% end




figure(101)
tile_size = [2,3];
t1 = tiledlayout(tile_size(1),tile_size(2));
tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);

for i0 = 12:1:numel(img_set_new.images)
    
    
    img_sample = img_set_new.images(i0).data;
    scores = mdl.project(img_sample(:));
    
    %plot the original images
    nexttile(tile_2d(1,1))
    imagesc(img_sample(:,:,1))
    title_str = img_set_new.images(i0).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');
    
    nexttile(tile_2d(2,1))
    imagesc(img_sample(:,:,2))
    title_str = img_set_new.images(i0).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');
    
    %plot estimated background and residual
    for i1 = 15%1:40%numel(scores)
        reci1 = mdl.reconstruct(scores(1:i1));
        reci1 = reshape(reci1,img_size);
        
        title_str = ['PCA projection for ' num2str(i1) ' components.'];
        nexttile(tile_2d(1,2))
        imagesc(reci1(:,:,1))
        title(title_str,'Interpreter','none');
        
        nexttile(tile_2d(2,2))
        imagesc(reci1(:,:,2))
        title(title_str,'Interpreter','none');
        drawnow();
        
        title_str  = 'residual';
        nexttile(tile_2d(1,3))
        imagesc(img_sample(:,:,1) - reci1(:,:,1))
        nexttile(tile_2d(2,3))
        imagesc(img_sample(:,:,2) - reci1(:,:,2))
        title(title_str);
        drawnow();
        pause(0.2);
    end
end
