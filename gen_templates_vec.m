load data/AllFbankdata_norm_memo.mat

n_tmpl_per_phone = 1600;
profile = '39c';

if strcmp(profile, 'foobar')
    phones = { ...
       [90 91 92],      ... % ih
       [159 160 161],   ... % uh
       [3 4 5],         ... % ae
       [0 1 2],         ... % aa
       [6 7 8],         ... % ah
       [144 145 146],   ... % s
       [135 136 137],   ... % pcl
       [129 130 131],   ... % p
       [84 85 86],      ... % hh
    };
elseif strcmp(profile, '39c')
    phones = { ...
        [96,97,98],
        [90,91,92,93,94,95],
        [48,49,50],
        [3,4,5],
        [15,16,17,6,7,8,18,19,20],
        [162,163,164,165,166,167],
        [159,160,161],
        [9,10,11,0,1,2],
        [69,70,71],
        [24,25,26],
        [126,127,128],
        [12,13,14],
        [123,124,125],
        [66,67,68,21,22,23],
        [108,109,110,51,52,53],
        [141,142,143],
        [171,172,173],
        [174,175,176],
        [111,112,113,54,55,56],
        [114,115,116,57,58,59,120,121,122],
        [117,118,119,60,61,62],
        [168,169,170],
        [72,73,74],
        [42,43,44],
        [156,157,158],
        [177,178,179],
        [144,145,146],
        [180,181,182,147,148,149],
        [99,100,101],
        [33,34,35],
        [27,28,29],
        [129,130,131],
        [36,37,38],
        [45,46,47],
        [150,151,152],
        [75,76,77],
        [102,103,104],
        [84,85,86,87,88,89],
        [30,31,32,39,40,41,78,79,80,135,136,137,153,154,155,105,106,107,63,64,65,132,133,134,81,82,83,138,139,140],
    };
elseif strcmp(profile, '61c')
    phones_m = reshape(1:183, 3, 61)';
    phones = cell(61,1);
    for i=1:length(phones)
        phones{i} = phones_m(:,i);
    end
else
    error('unknown profile: %s', profile);
end

tmpls_all = zeros(n_tmpl_per_phone*size(phones,1), size(traindata{1},2));

for ip = 1:length(phones)
    for it = 1:n_tmpl_per_phone

        while true
            % find a random phone
            ist = randsample(1:length(trainlab), 1);
            lab = trainlab{ist};
            idx = false(size(lab));
            for j = 1:length(phones{ip})
                idx = idx | (lab == phones{ip}(j));
            end
            idx = find(idx);
            if length(idx) < 1
                continue;
            end
            break;
        end
        
        tmpl_v = traindata{ist}(randsample(idx,1), :);
        tmpls_all((ip-1)*n_tmpl_per_phone + it, :) = tmpl_v / norm(tmpl_v);
    end
end

save(sprintf('data/templates/fbank-tmpls-%s-%d.mat', profile, n_tmpl_per_phone), 'tmpls_all', 'n_tmpl_per_phone');
