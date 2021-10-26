clear;
close all;
data_root = 'ica_models';

files = dir(fullfile(data_root,'*.mat'));

ica_mdls = cell(numel(files),1);
for i1 = 1:numel(files)
    pathi1 = fullfile(files(i1).folder,files(i1).name);
    d= load(pathi1);
    ica_mdls{i1} = d;
end

img_size = [41,41,2];

ica_mdls(cellfun(@(x) (x.ica_mdl.NumPredictors),ica_mdls) ~= prod(img_size)) = [];

[~,i_sort] = sort(cellfun(@(x) (x.ica_mdl.NumLearnedFeatures),ica_mdls));
ica_mdls = ica_mdls(i_sort);

% for i1 = 1:numel(ica_mdls)
%     ica_mdl_i1 = ica_mdls{i1};
%     wt = ica_mdl_i1.TransformWeights;
%     n_feat = size(wt,2);
%     np = ceil(sqrt(n_feat));
%     figure('Units','normalized','Position',[0 0 1 1]);
%     t1 = tiledlayout(np,np);
%     title(t1,num2str(n_feat))
%     for i2 = 1:n_feat
%         img_size = [sqrt(size(wt,1)/2),sqrt(size(wt,1)/2),2];
%         imgi2 = reshape(wt(:,i2),img_size);
%         imgi2 = cat(2,imgi2(:,:,1),imgi2(:,:,2));
%         nexttile();
%         imagesc(imgi2);
%     end
%
% end

s_select = struct('exozodi_intensity',2);
load('img_set.mat');
img_set_test = img_set.select('equal',s_select);
img_set_test = img_set_test.stack_by({'passband'});

% vidObj = VideoWriter('pca1.mp4','MPEG-4');
% vidObj.FrameRate = 1;
% vidObj.Quality = 100;
% open(vidObj);

figure(101)
set(gcf,'Color','white')
tile_size = [2,3];
t1 = tiledlayout(tile_size(1),tile_size(2));
t1.Padding = 'compact';
t1.TileSpacing = 'compact';
tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);

img_set_test.images = img_set_test.images(randperm(numel(img_set_test.images)));

for i0 = 1:numel(img_set_test.images)
    img_sample = img_set_test.images(i0).data_roi;
    img_size = size(img_sample);
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
    for i1 = 1:numel(ica_mdls)
        %         reci1 = mdl.reconstruct(scores(1:i1));
        d = ica_mdls{i1};
        mdl = d.ica_mdl;
        tw = mdl.TransformWeights;

        if all(ismember({'flips','rots'},fieldnames(d)))
            main_title = ['flips: ',  char(erase(formattedDisplayText(d.rots),newline)), ', rots: ' char(erase(formattedDisplayText(d.flips),newline))];
        else
            main_title = ['flips: NaN rots: NaN'];
        end



        if (~all(ismember({'flips','rots'},fieldnames(d))))||(~(numel(d.rots)==2)&&ismember(d.flips,[0 1],'rows'))
            continue
        end

        if ~(mdl.NumLearnedFeatures == 15)
            continue;
        end

        title(t1,main_title);
        dvect = img_sample(:)';
        scores = mdl.transform(dvect)';


        scores1 = dvect*tw;
%         score1 = tw
%         scores2 = robustfit(tw,dvect);


%        i_thresh = prctile(dvect,100*(numel(dvect)-5)/numel(dvect))/2;
        i_thresh = 0.5;
%         scores2 = robustfit(tw,dvect,'fair',i_thresh);
        scores2 = robustfit(tw,dvect,'huber',i_thresh);

        
        reci1_2 = tw*scores2(2:end) + scores2(1);
        reci1_2 = reshape(reci1_2,img_size);
        

        reci1 = tw*scores;


        reci1 = reshape(reci1,img_size);

        title_str = ['ICA model with ' num2str(mdl.NumLearnedFeatures) ' components.'];
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        title_str  = 'residual';
        nexttile(tile_2d(1,3))
        imagesc(img_sample(:,:,1) - reci1_2(:,:,1))
        colorbar;
        title(title_str);
        nexttile(tile_2d(2,3))
        imagesc(img_sample(:,:,2) - reci1_2(:,:,2))
        colorbar;
        title(title_str);
        drawnow();
        pause(1)


        %         currFrame = getframe(gcf);
        %         writeVideo(vidObj,currFrame);
    end
end
