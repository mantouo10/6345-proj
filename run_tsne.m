addpath tsne

% set pseudo random number generator
s = RandStream('mt19937ar','Seed',3085);
RandStream.setDefaultStream(s);

profile = 'rawfb-stk3-39c';
n_tmpl = 3200;
n_bin = 4;

n_train = 300;
classes = [1 21 41 61];

fprintf(1, '------------------- Experiment Summary --------------------\n');
fprintf(1, 'Features: %s-%d-%d\n', profile, n_tmpl, n_bin);
fprintf(1, '#Train: %d per class\n', n_train);
fprintf(1, '-----------------------------------------------------------\n');

% load data
fprintf(1, 'loading data...\n');
%load data/fbank-invariance-features-bigarray-compact-debug.mat
load(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%d.mat', profile, n_tmpl, n_bin));

trainlab_mg = 1+floor((trainlab-1)/3);

subset_idx = false(1,size(features_tr,1));

for i=1:length(classes)
    idx_i = find(trainlab_mg == classes(i));
    len = min([n_train, length(idx_i)]);
    rp = randperm(length(idx_i));
    subset_idx(idx_i(rp(1:len))) = true;
end
nor_features_tr = features_tr(subset_idx,:);
nor_labels = trainlab_mg(subset_idx);

fprintf(1, 'embedding....\n');
tic;
fea_embd = tsne(nor_features_tr, nor_labels, 2);
toc

