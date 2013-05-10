% convert matlab data to svmlight format
load data/fbank-invariance-features-bigarray-vec.mat

configs = {
  'data/fbank-vec-train.svmlight', features_tr, trainlab;
  'data/fbank-vec-dev.svmlight', features_dev, devsetlab
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
        fprintf(fid, '%d', labels_mg(j));
        fprintf(fid, ' %d:%f', txt(:));
        fprintf(fid, '\n');
    end
    fclose(fid);
end

