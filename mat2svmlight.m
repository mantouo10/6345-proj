% convert matlab data to svmlight format
profile = '61c';
n_bin = 4;
n_tmpl = 800;

load(sprintf('data/fbank-invariance-features-bigarray-%s-%d-%d.mat', profile, n_tmpl, n_bin));

configs = {
  sprintf('data/fbank-%s-train-%d-%d.svmlight', profile, n_tmpl, n_bin), features_tr, trainlab;
  sprintf('data/fbank-%s-dev-%d-%d.svmlight', profile, n_tmpl, n_bin) features_dev, devsetlab
};

for i = 1:size(configs,1)
    features = configs{i,2};
    labels = configs{i,3};
    labels_mg = 1+floor((labels-1)/3);

    fid = fopen(configs{i,1}, 'w');
    for j = 1:size(features,1)
        if rem(j, 1000) == 0
            fprintf(1, '%d\n', j);
        end
        txt = [1:size(features,2); features(j,:)];
        nz_idx = txt(2,:) ~= 0; % no need to write zero entries
        txt = txt(:, nz_idx);

        fprintf(fid, '%d', labels_mg(j));
        fprintf(fid, ' %d:%f', txt(:));
        fprintf(fid, '\n');
    end
    fclose(fid);
end

