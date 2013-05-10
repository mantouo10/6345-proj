load data/AllFbankdata_norm_memo.mat

phones = [90 91 92; ... % ih
    159 160 161;    ... % uh
    3 4 5;          ... % ae
    0 1 2;          ... % aa
    6 7 8;          ... % ah
    144 145 146;    ... % s
    135 136 137;    ... % pcl
    129 130 131;    ... % p
    84 85 86];          % hh

n_pos_per_phone = 4;
n_tmpl_per_pos  = 12;

tmpl_t_size = 5;
tmpl_f_size = 6;

%fb_band = [1 41; 42 82; 83 123];
fb_band = [1 41];

tmpls_all = zeros(tmpl_t_size, tmpl_f_size, ...
    length(phones), size(fb_band,1), ...
    n_pos_per_phone, n_tmpl_per_pos);

for ib = 1:size(fb_band,1)
    idx_cand = fb_band(ib,1):fb_band(ib,2);
    idx_cand(end-tmpl_f_size+2:end) = [];

    for ip = 1:length(phones)
        fprintf(1, 'Extracting templates from %d...\n', ip);
        for ippp = 1:n_pos_per_phone
            idx_f = randsample(idx_cand, 1);
            idf_t = rand();

            for itpp = 1:n_tmpl_per_pos
                % find a random phone
                while true
                    ist = randsample(1:length(trainlab), 1);
                    lab = trainlab{ist};
                    idx = (lab == phones(ip,1) | lab == phones(ip,2) | lab == phones(ip,3));
                    if sum(idx) < 1
                        continue;
                    end
                    idx_st = find(idx); idx_st = idx_st(1);
                    idx_ed = find(~idx(idx_st:end)); idx_ed = idx_ed(1)-1;
                    idx = idx_st:idx_st+idx_ed-1;

                    if length(idx) < tmpl_t_size
                        continue;
                    end

                    idx_t = floor(idf_t*(length(idx)-tmpl_t_size)) + 1;
                    break;
                end

                fb_st = traindata{ist};
                fb_st = fb_st(idx, :);
                tmpls_all(:,:,ip, ib, ippp, itpp) = fb_st(idx_t:idx_t+tmpl_t_size-1,...
                                                          idx_f:idx_f+tmpl_f_size-1);
            end
        end
    end
end

save('data/templates/fbank-tmpls-compact.mat', 'tmpls_all', 'fb_band');
