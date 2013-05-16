% since filter bank features are all positive
% when we calculate the cosine (normalized dot product)
% the results are concentrated around 1, which makes
% our magic feature very unfavorable...
load data/AllFbankdata_nonorm_memo.mat

traindata_tr = cell(size(traindata));
for i = 1:numel(traindata_tr)
    traindata_tr{i} = traindata{i}';
end

features = cell2mat(traindata_tr)';

the_mean = mean(features);
the_std = std(features);

for i = 1:numel(traindata)
    traindata{i} = bsxfun(@minus, traindata{i}, the_mean);
end
for i = 1:numel(devsetdata)
    devsetdata{i} = bsxfun(@minus, devsetdata{i}, the_mean);
end

save data/AllFbankdata_submean_memo.mat traindata devsetdata trainlab devsetlab

for i = 1:numel(traindata)
    traindata{i} = bsxfun(@rdivide, traindata{i}, the_std);
end
for i = 1:numel(devsetdata)
    devsetdata{i} = bsxfun(@rdivide, devsetdata{i}, the_std);
end

save data/AllFbankdata_unitstd_memo.mat traindata devsetdata trainlab devsetlab
