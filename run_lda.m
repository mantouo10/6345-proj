fprintf(1, 'do not run me ...\n');
return
data_tr = load('data/lda/timit-train.mat');
fprintf(1, 'load data done...\n');

features_tr = cell2mat(data_tr.fea);
labels_tr = [data_tr.gnd{:}];

phones = unique(labels_tr);
labels_num = zeros(size(labels_tr));
for i=1:length(phones)
    labels_num(strcmp(phones{i}, labels_tr)) = i;
end

W = LDA(features_tr', labels_num);
L = [ones(length(labels_num), 1) features_tr'] * W';

[~,I] = max(L, [], 2);
accuracy = sum(I' == labels_num)/length(labels_num);
fprintf(1, 'Training accuracy: %.2f%%\n', accuracy*100);

% accuracy on test set
data_dev = load('data/lda/timit-dev.mat');
fprintf(1, 'load dev data done...\n');

features_tt = cell2mat(data_dev.fea);
labels_tt = [data_dev.gnd{:}];

labels_num_tt = zeros(size(labels_tt));
for i=1:length(phones)
    labels_num_tt(strcmp(phones{i}, labels_tt)) = i;
end

L_tt = [ones(length(labels_num_tt), 1) features_tt'] * W';
[~,I_tt] = max(L_tt,[],2);
accuracy_tt = sum(I_tt' == labels_num_tt)/length(labels_num_tt);
fprintf(1, 'Test accuracy: %.2f%%\n', accuracy_tt*100);
