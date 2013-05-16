addpath libsvm/libsvm-3.17/matlab

% set pseudo random number generator
s = RandStream('mt19937ar','Seed',3085);
RandStream.setDefaultStream(s);

profile = '61c';
n_tmpl = 3200;
n_bin = 4;

libsvm_param = '-s 0 -t 1 -c 100 -d 50';
n_train = 500;
normalization = 'none';

fprintf(1, '------------------- Experiment Summary --------------------\n');
fprintf(1, 'Features: %s-%d-%d\n', profile, n_tmpl, n_bin);
fprintf(1, '#Train: %d per class\n', n_train);
fprintf(1, 'Normalization: %s\n', normalization);
fprintf(1, 'Classifier: %s\n', libsvm_param);
fprintf(1, '-----------------------------------------------------------\n');

% load data
fprintf(1, 'loading data...\n');
%load data/fbank-invariance-features-bigarray-compact-debug.mat
%load data/fbank-stack1.mat
load(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%d.mat', profile, n_tmpl, n_bin));

trainlab_mg = 1+floor((trainlab-1)/3);
devsetlab_mg = 1+floor((devsetlab-1)/3);

subset_idx = false(1,size(features_tr,1));
classes = unique(trainlab_mg);
for i=1:length(classes)
    idx_i = find(trainlab_mg == i);
    len = min([n_train, length(idx_i)]);
    rp = randperm(length(idx_i));
    subset_idx(idx_i(rp(1:len))) = true;
end
nor_features_tr = features_tr(subset_idx,:);
nor_features_dev = features_dev;

if strcmp(normalization, 'pca')
    fprintf(1, 'normalizing features...\n');
    % PCA Whiten
    the_mean = mean(nor_features_tr);
    X = bsxfun(@minus, nor_features_tr, the_mean);
    [V, D] = eig(X'*X);
    D = diag(D);
    D(D ~= 0) = 1;
    V = V(:,D~=0); D = D(D ~= 0);

    W = V*diag(D)*V';
    nor_features_tr = X*W;
    nor_features_dev = bsxfun(@minus, nor_features_dev, the_mean)*W;
elseif strcmp(normalization, 'none')
    % do nothing
else
    error('unknown normalization: %s', normalization);
end

rp = randperm(length(devsetlab_mg));
ntest = 3000;

fprintf(1, 'training....\n');
tic;
model = svmtrain(double(trainlab_mg(subset_idx))', sparse(double(nor_features_tr)), libsvm_param);
toc
fprintf(1, 'predicting....\n');
[I, acc, decval] = svmpredict(double(devsetlab_mg(rp(1:ntest)))', sparse(double(nor_features_dev(rp(1:ntest),:))), model);
