load data/fbank-invariance-features-bigarray-compact-debug.mat

trainlab_mg = 1+floor((trainlab-1)/3);
devsetlab_mg = 1+floor((devsetlab-1)/3);

W = LDA(features_tr, trainlab_mg);
L = [ones(length(trainlab_mg), 1) features_tr] * W';

[~,I] = max(L, [], 2);
accuracy = sum(I' == trainlab_mg)/length(trainlab_mg);
fprintf(1, 'Training accuracy: %.2f%%\n', accuracy*100);

L_tt = [ones(length(devsetlab_mg),1) features_dev] * W';
[~,I_tt] = max(L_tt,[],2);
accuracy_tt = sum(I_tt' == devsetlab_mg)/length(devsetlab_mg);
fprintf(1, 'Test accuracy: %.2f%%\n', accuracy_tt*100);
