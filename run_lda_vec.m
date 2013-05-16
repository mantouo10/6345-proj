n_tmpl = 3200;
pool_profile = 'mean';
profile = 'stk5-61c';
combine_fbank = 0;
normalization = 'none';

fprintf(1, '--- LDA -------------------\n');
fprintf(1, 'profile: %s\n', profile);
fprintf(1, 'n_tmpl: %d\n', n_tmpl);
fprintf(1, 'pool_profile: %s\n', pool_profile);
fprintf(1, 'normalization: %s\n', normalization);
fprintf(1, '---------------------------\n');

load(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%s.mat', profile, n_tmpl, pool_profile));
%load data/fbank-stack1.mat

if combine_fbank
    fprintf(1, 'combining with fbank feature...\n');
    fbank_data = load('data/fbank-invariance-features-bigarray-compact-debug.mat');
    features_tr = [features_tr fbank_data.features_tr];
    features_dev = [features_dev fbank_data.features_dev];
end

trainlab_mg = 1+floor((trainlab-1)/3);
devsetlab_mg = 1+floor((devsetlab-1)/3);

nor_features_tr = features_tr;
nor_features_dev = features_dev;

fprintf(1, 'normalizing features...\n');
if strcmp(normalization, 'whiten-spec') || strcmp(normalization, 'whiten-tiknov') || strcmp(normalization, 'pca')
    % PCA Whiten
    the_mean = mean(nor_features_tr);
    X = bsxfun(@minus, nor_features_tr, the_mean);
    [V, D] = eig(X'*X);
    D = diag(D);
    if strcmp(normalization, 'whiten-spec')
        D(D ~= 0) = 1 ./ sqrt(D(D ~= 0));
    elseif strcmp(normalization, 'whiten-tiknov')
        D = 1 ./ sqrt(1e-5 + D);
    elseif strcmp(normalization, 'pca')
        D(D ~= 0) = 1;
    end
    V = V(:,D~=0); D = D(D ~= 0);

    W = V*diag(D)*V';
    nor_features_tr = X*W;
    nor_features_dev = bsxfun(@minus, nor_features_dev, the_mean)*W;
elseif strcmp(normalization, 'none')
    % do nothing
else
    error('unknown normalization: %s', normalization);
end

W = LDA(nor_features_tr, trainlab_mg);
L = [ones(length(trainlab_mg), 1) nor_features_tr] * W';

[~,I] = max(L, [], 2);
accuracy = sum(I' == trainlab_mg)/length(trainlab_mg);
fprintf(1, 'Training accuracy: %.2f%%\n', accuracy*100);

L_tt = [ones(length(devsetlab_mg),1) nor_features_dev] * W';
[~,I_tt] = max(L_tt,[],2);
accuracy_tt = sum(I_tt' == devsetlab_mg)/length(devsetlab_mg);
fprintf(1, 'Test accuracy: %.2f%%\n', accuracy_tt*100);
