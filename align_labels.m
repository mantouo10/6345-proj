% Concatinate all features frames and align label for each from
% Preparation for LDA
fea_dir = 'data/features';
raw_dir = 'data/timit_data/spec/clean';

files = dir([fea_dir '/*.mat']);
features = cell(1, length(files));
labels = cell(1, length(files));
mask = zeros(1, length(files)); % 1-train, 2-test, 0-none

trainfiles = fileread('data/timit_split/train_wav_list.txt');
devfiles = fileread('data/timit_split/dev_wav_list.txt');

for i = 1:length(files)
    fprintf(1, '%04d/%04d: %s...\n', i, length(files), files(i).name);
    key = strrep(files(i).name(1:end-4), '-m-', '-b-');
    if ~isempty(strfind(trainfiles, key))
        mask(i) = 1;
    elseif ~isempty(strfind(devfiles, key))
        mask(i) = 2;
    else
        fprintf(1, '    skipping...\n');
        continue;
    end

    fea = load([fea_dir '/' files(i).name]);
    lbl = load([raw_dir '/' files(i).name(1:end-3) 'spec'], '-mat');

    f_fea = fea.fea;
    f_label = cell(1, size(f_fea, 2));
    for j=1:length(lbl.st_ix)
        ist = lbl.st_ix(j)+1;
        ied = lbl.end_ix(j);
        %ist_spec = ceil((ist-1)/(lbl.winSize-lbl.nOL))+1;
        ist_spec = floor((ist-1)/(lbl.winSize-lbl.nOL))+1;
        %ied_spec = floor((ied-lbl.winSize)/(lbl.winSize-lbl.nOL));
        ied_spec = ceil((ied-lbl.winSize)/(lbl.winSize-lbl.nOL));

        f_idx = 1:length(f_label);
        f_idx = f_idx >= (ist_spec-1)/3 + 1 & f_idx <= (ied_spec-1)/3 + 1;
        f_label(f_idx) = arrayfun(@(x) lbl.labels{j}, 1:sum(f_idx), 'UniformOutput', false);
    end

    idx = ~cellfun(@isempty, f_label);
    features{i} = f_fea(:, idx);
    labels{i} = f_label(idx);
    fprintf(1, '    %d out of %d frames retained...\n', sum(idx), length(f_label));
end

fea = features(mask == 1);
gnd = labels(mask == 1);
save data/lda/timit-train.mat -v7.3 'fea' 'gnd'

fea = features(mask == 2);
gnd = labels(mask == 2);
save data/lda/timit-dev.mat -v7.3 'fea' 'gnd'


fprintf(1, '=======================\n');
fprintf(1, '%d sentences for training\n', sum(mask == 1));
fprintf(1, '%d sentences for dev\n', sum(mask == 2));
fprintf(1, '%d sentences ignored\n', sum(mask == 0));
