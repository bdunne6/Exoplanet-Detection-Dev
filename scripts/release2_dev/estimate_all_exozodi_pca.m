addpath(genpath(fullfile('..','..','src')))

img_folder = 'D:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';
output_folder = 'pca_models';

img_set = StarshadeImageSet(img_folder,1);
img_set.roi = [13,13,41,41];
% save('img_set.mat','img_set');

%load('img_set.mat');


% s_select = struct('snr_level',3,'exozodi_intensity',2);
% s_select = struct('snr_level',3);




% s_select = struct('exozodi_model','rez','exozodi_intensity',3);
% s_select = struct('exozodi_model','rez','exozodi_intensity',3);
% s_select = struct('exozodi_model','rez','exozodi_intensity',3);
% % s_select = struct('exozodi_intensity',2);
% % s_select = struct();
% [img_set_train1, i_equal] = img_set.select('equal',s_select);
%
% s_select = struct('exozodi_model','rez','exozodi_intensity',2);
% % s_select = struct('exozodi_intensity',2);
% % s_select = struct();
% [img_set_train2, i_equal] = img_set.select('equal',s_select);
%
% img_set_train = img_set;
% img_set_train.images = cat(2,img_set_train1.images,img_set_train2.images);

[~, i_eq1] = img_set.select('equal',struct('exozodi_intensity',3));
[~, i_eq2] = img_set.select('equal',struct('exozodi_intensity',2));

img_set_train = img_set.index(i_eq1|i_eq2);

img_set_train = img_set_train.stack_by({'passband'});


X = [];
% rots = [0,1,2,3];
rots = [0,2];
%rots = [0];
flips = [0,1];
for i0 = 1:numel(flips)
    for i1 = 1:numel(rots)
        Xi0 = zeros(numel(img_set_train.images),numel(img_set_train.images(1).data_roi));
        img_size = size(img_set_train.images(1).data_roi);
        for i2 = 1:numel(img_set_train.images)
            imgi1 = img_set_train.images(i2).data_roi;
            imgi1 = rot90(imgi1,rots(i1));
            if i0
                imgi1 = flip(imgi1,2);
            end
            Xi0(i2,:) = imgi1(:);
        end
        X = cat(1,X,Xi0);
    end
end


% for i1 = 1:numel(img_set_train.images)
%     imgi1 = img_set_train.images(i1).data;
%     imgi1 =  rot90(imgi1,2);
%     X(i1+numel(img_set_train.images),:) = imgi1(:);
% end

pca_args = {X,1,0};
pca_mdl = pca_model(pca_args{:});

mdl_name = fullfile(output_folder,['pca_',num2str(numel(pca_mdl.latent)),'_',DataHash(pca_args),'.mat']);
save(mdl_name,'pca_mdl','img_set_train','rots','flips');

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

s_select = struct('scenario',5,'exozodi_intensity',2,'snr_level',3,'visit_num',2);
% img_set_test = img_set.select('equal',s_select);
% img_set_test = img_set_test.stack_by({'passband'});
img_set_test = img_set.copy();
img_set_test = img_set_test.stack_by({'passband'});

vidObj = VideoWriter('pca1.mp4','MPEG-4');
vidObj.FrameRate = 1;
vidObj.Quality = 100;
open(vidObj);

s.file_name = 'sister_R05_v2_rez2_snr3_0425_0552_nm_r2.fits';
img_set_test = img_set_test.select('equal',s);
for i1 = 1:numel(img_set_test.images)

    img_sample = img_set_test.images(i1).data_roi;
    scores = pca_mdl.project(img_sample(:));

    %plot the original images
    nexttile(tile_2d(1,1))
    imagesc(img_sample(:,:,1))
    colorbar;
    title_str = img_set_test.images(i1).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');

    nexttile(tile_2d(2,1))
    imagesc(img_sample(:,:,2))
    colorbar;
    title_str = img_set_test.images(i1).meta(2).file_name(8:end-5);
    title(title_str,'Interpreter','none');

    %plot estimated background and residual
    for i2 = 9:17%1:40%numel(scores)
        reci1 = pca_mdl.reconstruct(scores(1:i2));
        reci1 = reshape(reci1,img_size);

        title_str = ['PCA model with ' num2str(i2) ' components.'];
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
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
    end
end
close(vidObj);
