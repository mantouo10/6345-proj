addpath liblinear/liblinear-1.93/matlab

n_tmpl = 1600;
n_bin = 4;

% load data
if ~exist('features_tr', 'var') || size(features_tr,2) ~= n_bin*61
    fprintf(1, 'loading data...\n');
    load(sprintf('data/fbank-invariance-features-bigarray-vec-%d-%d.mat', n_tmpl, n_bin));
    fprintf(1, 'load data done...\n');
end

trainlab_mg = 1+floor((trainlab-1)/3);
devsetlab_mg = 1+floor((devsetlab-1)/3);

n_train = 6000;
subset_idx = false(1,size(features_tr,1));
classes = unique(trainlab_mg);
for i=1:length(classes)
    idx_i = find(trainlab_mg == i);
    len = min([n_train, length(idx_i)]);
    rp = randperm(length(idx_i));
    subset_idx(idx_i(rp(1:len))) = true;
end

fprintf(1, 'training....\n');
model = train(double(trainlab_mg(subset_idx))', sparse(double(features_tr(subset_idx,:))), '-s 2');
fprintf(1, 'predicting....\n');
[I, acc] = predict(double(devsetlab_mg)', sparse(double(features_dev)), model);
