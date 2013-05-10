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

phones = reshape(1:183, 3, 61)';

n_tmpl_per_phone = 3200;
tmpls_all = zeros(n_tmpl_per_phone*size(phones,1), size(traindata{1},2));

for ip = 1:length(phones)
    for it = 1:n_tmpl_per_phone

        while true
            % find a random phone
            ist = randsample(1:length(trainlab), 1);
            lab = trainlab{ist};
            idx = find(lab == phones(ip,1) | lab == phones(ip,2) | lab == phones(ip,3));
            if length(idx) < 1
                continue;
            end
            break;
        end
        
        tmpl_v = traindata{ist}(randsample(idx,1), :);
        tmpls_all((ip-1)*n_tmpl_per_phone + it, :) = tmpl_v / norm(tmpl_v);
    end
end

save(sprintf('data/templates/fbank-tmpls-vector-%d.mat', n_tmpl_per_phone), 'tmpls_all', 'n_tmpl_per_phone');
