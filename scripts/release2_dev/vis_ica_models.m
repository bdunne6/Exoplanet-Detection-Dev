clear;
close all;
data_root = 'ica_models_1em9_std';

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

for i1 = 1:numel(ica_mdls)
    d = ica_mdls{i1};
    mdl = d.ica_mdl;

    if (~all(ismember({'flips','rots'},fieldnames(d))))||(~(numel(d.rots)==2)&&ismember(d.flips,[0 1],'rows'))
        continue
    end


    wt = mdl.TransformWeights;
    n_feat = size(wt,2);
    np = ceil(sqrt(n_feat));
    figure('Units','normalized','Position',[0 0 1 1]);
    t1 = tiledlayout(np,np);
    title(t1,num2str(n_feat))
    for i2 = 1:n_feat
        img_size = [sqrt(size(wt,1)/2),sqrt(size(wt,1)/2),2];
        imgi2 = reshape(wt(:,i2),img_size);
        imgi2 = cat(2,imgi2(:,:,1),imgi2(:,:,2));
        nexttile();
        imagesc(imgi2);
        title(['ICA comp #' num2str(i2)]);
    end

end
