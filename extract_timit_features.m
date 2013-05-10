input_dir = 'data/timit_data/spec/clean';
output_dir = 'data/features';

load('data/templates/15-40-all.mat');
files = dir([input_dir '/*.spec']);

do_save = @(fn, fea) save(fn, 'fea');

parfor i=1:length(files)
    fprintf(1, 'Extracting %s...\n', files(i).name);
    ifn = [input_dir '/' files(i).name];
    data = load(ifn, '-mat');
    fea = extract_frame_feature2(data.S, tmpls_all);
    ofn = [output_dir '/' files(i).name(1:end-4) 'mat'];
    do_save(ofn, fea);
end
