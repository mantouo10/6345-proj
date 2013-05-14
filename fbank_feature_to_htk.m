load data/fbank-invariance-features-stk3-61c-3200-6.mat

configs = { ...
  {features_tr, trainlab, 'data/htk-train-stk3-61c-6', 'data/train_data_order.txt'},  ...
  {features_dev, devsetlab, 'data/htk-dev-stk3-61c-6', 'data/dev_data_order.txt'}   ...
};

for ii = 1:length(configs)
    features = configs{ii}{1};
    labels = configs{ii}{2};
    outputdir = configs{ii}{3};
    tagfile = configs{ii}{4};

    fprintf(1, 'scanning tag file...\n');
    fid = fopen(tagfile);
    a = textscan(fid,'%[^-b]-b-%s');
    fclose(fid);

    utt = a{1};
    spk = a{2};
    for i = 1:length(utt)
        fprintf(1, '%d / %d...\n', i, length(utt));
        targetdir = [outputdir '/' spk{i}];
        if ~isdir(targetdir); mkdir(targetdir); end

        % write data
        targetfile = [targetdir '/' utt{i} '-b-' spk{i} '.mfsc'];
        writehtk(targetfile, features{i}, 0.01, 6);

        % write label
        fid = fopen([targetfile(1:end-4) 'label'],'w');
        label = labels{i};
        label = label(1:size(features{i},1));
        label = 1+floor((label-1)/3); % map 183 classes back to 61 classes
        for j = 1:length(label)
            fprintf(fid,'%d\n',label(j));
        end
        fclose(fid);
    end

end
