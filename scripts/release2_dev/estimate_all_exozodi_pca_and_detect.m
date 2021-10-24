addpath(genpath(fullfile('..','..','src')))

img_folder = 'D:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';

% img_set = StarshadeImageSet(img_folder,1);
% save('img_set.mat','img_set');

load('img_set.mat');


% s_select = struct('snr_level',3,'exozodi_intensity',2);
% s_select = struct('snr_level',3);




% s_select = struct('exozodi_model','rez','exozodi_intensity',3);
% s_select = struct('exozodi_model','rez','exozodi_intensity',3);
s_select = struct('exozodi_model','rez','exozodi_intensity',3);
% s_select = struct('exozodi_intensity',2);
% s_select = struct();
[img_set_train1, i_equal] = img_set.select('equal',s_select);

s_select = struct('exozodi_model','rez','exozodi_intensity',2);
% s_select = struct('exozodi_intensity',2);
% s_select = struct();
[img_set_train2, i_equal] = img_set.select('equal',s_select);

s_select = struct('exozodi_model','rez','exozodi_intensity',3);
img_set_train = img_set.select();
img_set_train.images = cat(2,img_set_train1.images,img_set_train2.images);

%img_set_train = img_set_train2;

img_set_train = img_set.select('');
img_set_train = img_set_train.stack_by({'passband'});


X = [];
% rots = [0,1,2,3];
rots = [0,2];

for i0 = 1:numel(rots)
    Xi0 = zeros(numel(img_set_train.images),numel(img_set_train.images(1).data));
    img_size = size(img_set_train.images(1).data);
    for i1 = 1:numel(img_set_train.images)
        imgi1 = img_set_train.images(i1).data;
        imgi1 = rot90(imgi1,rots(i0));
        Xi0(i1,:) = imgi1(:);
    end
    X = cat(1,X,Xi0);
end


% for i1 = 1:numel(img_set_train.images)
%     imgi1 = img_set_train.images(i1).data;
%     imgi1 =  rot90(imgi1,2);
%     X(i1+numel(img_set_train.images),:) = imgi1(:);
% end

mdl = pca_model(X,1,0);



% figure;
% img_mean = reshape(mdl.Xm,img_size);
% imagesc(img_mean(:,:,2))


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
set(gcf,'Color','white')
tile_size = [2,3];
t1 = tiledlayout(tile_size(1),tile_size(2));
t1.Padding = 'compact';
t1.TileSpacing = 'compact';
tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);

s_select = struct('exozodi_intensity',2,'snr_level',3);
img_set_test = img_set.select('equal',s_select);
img_set_test = img_set_test.stack_by({'passband'});

for i0 = 1:numel(img_set_test.images)
    figure(101)
    img_sample = img_set_test.images(i0).data;
    scores = mdl.project(img_sample(:));
    
    %plot the original images
    nexttile(tile_2d(1,1))
    imagesc(img_sample(:,:,1))
    colorbar;
    title_str = img_set_test.images(i0).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');
    
    nexttile(tile_2d(2,1))
    imagesc(img_sample(:,:,2))
    colorbar;
    title_str = img_set_test.images(i0).meta(2).file_name(8:end-5);
    title(title_str,'Interpreter','none');
    

    %plot estimated background and residual
    for i1 = 10%1:40%numel(scores)
        reci1 = mdl.reconstruct(scores(1:i1));
        reci1 = reshape(reci1,img_size);
        
        title_str = ['PCA model with ' num2str(i1) ' components.'];
        nexttile(tile_2d(1,2))
        imagesc(reci1(:,:,1))
        colorbar;
        title(title_str,'Interpreter','none');
        
        nexttile(tile_2d(2,2))
        imagesc(reci1(:,:,2))
        colorbar;
        title(title_str,'Interpreter','none');
        
        title_str  = 'residual';
        nexttile(tile_2d(1,3))
        imagesc(img_sample(:,:,1) - reci1(:,:,1))
        colorbar;
        title(title_str);
        nexttile(tile_2d(2,3))
        imagesc(img_sample(:,:,2) - reci1(:,:,2))
        colorbar;
        title(title_str);
        drawnow();
        pause(0.5);
    end
    
    r1 = img_sample(:,:,1) - reci1(:,:,1);
    r2 = img_sample(:,:,2) - reci1(:,:,2);
    rg = r1 + r2;
    [cent_xy,g_ind] = planet_detection(rg,2);
    
    figure(102);
    subplot(2,1,1)
    imgg = img_sample(:,:,1)+img_sample(:,:,2);
    imagesc(imgg);
    caxis([0 max(imgg(:))])
        title_str = img_set_test.images(i0).meta(2).file_name(8:end-5);
    title(title_str,'Interpreter','none');
    subplot(2,1,2)
    imagesc(rg)
        caxis([min(rg(:)) max(rg(:))])
    %cent_xy = [cm,rm];
    hold on;
    plot(cent_xy(:,1),cent_xy(:,2),'.r')
    
end




% bin = imregionalmax(rg);
% % imagesc(bin)
% [rm,cm] = find(bin);
% ind = sub2ind(size(rg),rm,cm);
% g_ind = rg(ind);
%
% [g_ind,i_s] = sort(g_ind,'descend');
% cent_xy = [cm(i_s(1:2)),rm(i_s(1:2))];



% figure;
% imagesc(rg)
% %cent_xy = [cm,rm];
% hold on;
% plot(cent_xy(:,1),cent_xy(:,2),'.r')




