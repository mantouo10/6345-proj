clear
n_bin = 'mean';
n_tmpl = 3200;
profile = 'stk5-61c';
n_fband = 1;

load(sprintf('data/templates/fbank-tmpls-%s-%d.mat', profile, n_tmpl));
if ~exist('use_delta', 'var')
    use_delta = 1;
end
if ~exist('stack_num', 'var')
    stack_num = 0;
end
if ~exist('which_fbank', 'var')
    which_fbank = 'whiten';
end

if strcmp(which_fbank, 'whiten')
    load data/AllFbankdata_nonorm_memo.mat
elseif strcmp(which_fbank, 'submean')
    load data/AllFbankdata_submean_memo.mat
elseif strcmp(which_fbank, 'unitstd')
    load data/AllFbankdata_unitstd_memo.mat
else
    error('Unknown fbank feature: %s', which_fbank);
end


features_tr = cell(size(traindata));
n_train = length(features_tr);
if n_fband > 1
    profile = sprintf('bnd%d-%s', n_fband, profile);
end

parfor i=1:n_train
    fprintf(1, '%d / %d...\n', i, n_train);
    features_tr{i} = extract_frame_feature_vec(do_stack(traindata{i}, stack_num, use_delta), ...
        tmpls_all, n_tmpl_per_phone, n_bin, n_fband);
end

features_dev = cell(size(devsetdata));
n_dev = length(features_dev);
parfor i=1:n_dev
    fprintf(1, '%d / %d...\n', i, n_dev);
    features_dev{i} = extract_frame_feature_vec(do_stack(devsetdata{i}, stack_num, use_delta), ...
        tmpls_all, n_tmpl_per_phone, n_bin, n_fband);
end

if isnumeric(n_bin)
    pool_profile = sprintf('%d', n_bin);
else
    pool_profile = n_bin;
end
save(sprintf('data/fbank-invariance-features-%s-%d-%s.mat', profile, n_tmpl, pool_profile), '-v7.3', 'features_tr', 'features_dev', 'trainlab', 'devsetlab');

%load(sprintf('data/fbank-invariance-features-%s-%d-%s.mat', profile, n_tmpl, pool_profile));

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

save(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%s.mat', profile, n_tmpl, pool_profile), '-v7.3', 'features_tr', 'features_dev', 'trainlab', 'devsetlab');
