function [spec, seed] = get_phone(seed)
% Get the spectrogram of a given phone.
% The first time, pass in the phone label as the seed. The
% returned seed should be passed as argument for all the
% successive calls of the same group.
%
% e.g.
%  [ao1, ao_seed] = get_phone('ao');
%  [ao2, ao_seed] = get_phone(ao_seed);

if ischar(seed)
    seed = struct('label', seed);
    seed.basedir = 'data/timit_data/spec/clean';
    specs = dir([seed.basedir '/*.spec']);
    seed.specs = specs(randperm(length(specs)));
    seed.idx = 0;
end

while true
    seed.idx = seed.idx + 1;
    data = load([seed.basedir '/' seed.specs(seed.idx).name], '-mat');
    idx = find(strcmp(data.labels, seed.label));
    if isempty(idx)
        continue;
    end
    
    idx = randsample(idx, 1);
    ist = data.st_ix(idx)+1;
    ied = data.end_ix(idx);
    ist_spec = ceil((ist-1)/(data.winSize-data.nOL))+1;
    ied_spec = floor((ied-data.winSize)/(data.winSize-data.nOL));
    spec = data.S(:,ist_spec:ied_spec);
    break;
end

end
