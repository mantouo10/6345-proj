load data/fbank-invariance-features-bigarray-vec.mat
%load data/fbank-invariance-features-bigarray-compact-debug.mat

trainlab_mg = 1+floor((trainlab-1)/3);
devsetlab_mg = 1+floor((devsetlab-1)/3);

classes = unique(trainlab_mg);
means = zeros(length(classes), size(features_tr,2));
for i=1:length(classes)
    idx = (trainlab_mg == i);
    %fprintf(1, 'class %d, %d samples\n', i, sum(idx));
    means(i,:) = mean(features_tr(idx,:));
end

dist = EuDist2(means, features_tr, false);
[~,I] = min(dist);

accuracy = sum(I == trainlab_mg)/length(trainlab_mg);
accuracy
