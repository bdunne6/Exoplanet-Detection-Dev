clear;
close all;
% data_root = 'ica_models_1em9_std';
data_root = 'pca_models';

files = dir(fullfile(data_root,'*.mat'));

pca_mdls = cell(numel(files),1);
for i1 = 1:numel(files)
    pathi1 = fullfile(files(i1).folder,files(i1).name);
    d= load(pathi1);
    pca_mdls{i1} = d;
end

img_size = [41,41,2];

pca_mdls(cellfun(@(x) (size(x.pca_mdl.coeff,1)),pca_mdls) ~= prod(img_size)) = [];

[~,i_sort] = sort(cellfun(@(x) (size(x.pca_mdl.coeff,1)),pca_mdls));
pca_mdls = pca_mdls(i_sort);

n_feat = 17;
for i1 = 1:numel(pca_mdls)
    d = pca_mdls{i1};
    mdl = d.pca_mdl;

    if (~all(ismember({'flips','rots'},fieldnames(d))))||(~(numel(d.rots)==2)&&ismember(d.flips,[0 1],'rows'))
        continue
    end

    wt = mdl.coeff;
    np = ceil(sqrt(n_feat));
    figure('Units','normalized','Position',[0 0 1 1]);
    t1 = tiledlayout(6,3);
    t1.Padding = 'compact';
    t1.TileSpacing = 'compact';
    title(t1,num2str('PCA model components'))
    for i2 = 1:n_feat
        img_size = [sqrt(size(wt,1)/2),sqrt(size(wt,1)/2),2];
        imgi2 = reshape(wt(:,i2),img_size);
        imgi2 = cat(2,imgi2(:,:,1),imgi2(:,:,2));
        nexttile();
        imagesc(imgi2);
        title(['PCA comp #' num2str(i2)]);
    end

end
