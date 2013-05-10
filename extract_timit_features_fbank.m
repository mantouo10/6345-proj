clear
load data/AllFbankdata_norm_memo.mat
load data/templates/fbank-tmpls-compact.mat

features_tr = cell(size(traindata));
n_train = length(features_tr);

parfor i=1:n_train
    fprintf(1, '%d / %d...\n', i, n_train);
    features_tr{i} = extract_frame_feature_debug(traindata{i}, tmpls_all, fb_band);
end

features_dev = cell(size(devsetdata));
n_dev = length(features_dev);
parfor i=1:n_dev
    fprintf(1, '%d / %d...\n', i, n_dev);
    features_dev{i} = extract_frame_feature_debug(devsetdata{i}, tmpls_all, fb_band);
end

save data/fbank-invariance-features-compact-debug.mat -v7.3 'features_tr' 'features_dev' 'trainlab' 'devsetlab'

%load data/fbank-invariance-features.mat

n_train = length(features_tr);
for i=1:n_train
    len = size(features_tr{i},1);
    lab = trainlab{i};
    trainlab{i} = lab(1:len)';
    features_tr{i} = features_tr{i}';
end

n_dev = length(features_dev);
for i=1:n_dev
    len = size(features_dev{i},1);
    lab = devsetlab{i};
    devsetlab{i} = lab(1:len)';
    features_dev{i} = features_dev{i}';
end

features_tr = cell2mat(features_tr)';
features_dev = cell2mat(features_dev)';
trainlab = [trainlab{:}];
devsetlab = [devsetlab{:}];

save data/fbank-invariance-features-bigarray-compact-debug.mat -v7.3 'features_tr' 'features_dev' 'trainlab' 'devsetlab'
