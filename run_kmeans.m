addpath kmeans

% set pseudo random number generator
s = RandStream('mt19937ar','Seed',3085);
RandStream.setDefaultStream(s);

profile = '61c';
n_tmpl = 3200;
n_bin = 15;

n_train = inf;
normalization = 'none';
combine_fbank = 0;

fprintf(1, '------------------- Experiment Summary --------------------\n');
fprintf(1, 'Features: %s-%d-%d\n', profile, n_tmpl, n_bin);
fprintf(1, '#Train: %d per class\n', n_train);
fprintf(1, 'Normalization: %s\n', normalization);
fprintf(1, 'Combine filterbank: %d\n', combine_fbank);
fprintf(1, '-----------------------------------------------------------\n');

% load data
fprintf(1, 'loading data...\n');
%load data/fbank-invariance-features-bigarray-compact-debug.mat
load(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%d.mat', profile, n_tmpl, n_bin));

if combine_fbank
    fprintf(1, 'combining with fbank feature...\n');
    fbank_data = load('data/fbank-invariance-features-bigarray-compact-debug.mat');
    features_tr = [features_tr fbank_data.features_tr];
    features_dev = [features_dev fbank_data.features_dev];
end

trainlab_mg = 1+floor((trainlab-1)/3);

subset_idx = false(1,size(features_tr,1));
classes = unique(trainlab_mg);
for i=1:length(classes)
    idx_i = find(trainlab_mg == i);
    len = min([n_train, length(idx_i)]);
    rp = randperm(length(idx_i));
    subset_idx(idx_i(rp(1:len))) = true;
end
nor_features_tr = features_tr(subset_idx,:);

fprintf(1, 'normalizing features...\n');
if strcmp(normalization, 'pca')
    % PCA Whiten
    the_mean = mean(nor_features_tr);
    X = bsxfun(@minus, nor_features_tr, the_mean);
    [V, D] = eig(X'*X);
    D = diag(D);
    D(D ~= 0) = 1;
    V = V(:,D~=0); D = D(D ~= 0);

    W = V*diag(D)*V';
    nor_features_tr = X*W;
elseif strcmp(normalization, 'none')
    % do nothing
else
    error('unknown normalization: %s', normalization);
end

fprintf(1, 'Clustering...\n');
km_labels = litekmeans(double(nor_features_tr), 61);

fprintf(1, 'Evaluating...\n');
km_labels = bestMap(trainlab_mg', km_labels);
accuracy = sum(km_labels == trainlab_mg')/length(trainlab_mg);

fprintf(1, 'Accuracy: %.4f\n', accuracy);
