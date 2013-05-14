n_tmpl_per_phone = 3200;
profile = '39c';
% whether enforce every speaker contributes the same # of templates
balance_speaker = 0; 
use_delta = 0;
stack_num = 3;
raw_fbank = 1; % use un-whiten-ed fbank for feature extraction

if raw_fbank
    load data/AllFbankdata_nonorm_memo.mat
else
    load data/AllFbankdata_norm_memo.mat
end

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
    phones_m = reshape(1:183, 3, 61);
    phones = cell(61,1);
    for i=1:length(phones)
        phones{i} = phones_m(:,i);
    end
else
    error('unknown profile: %s', profile);
end

if balance_speaker
    spk = load('speaker_index.mat');
    spk_index = logical(spk.index);
else
    % pretend there is only one speaker
    spk_index = true(1, length(trainlab));
end

speaker_num = size(spk_index, 1);
nt_per_spk = ceil(n_tmpl_per_phone/speaker_num);
n_tmpl_per_phone_real = nt_per_spk*speaker_num;

tmp = do_stack(traindata{1}, stack_num, use_delta);
tmpls_all = zeros(n_tmpl_per_phone_real*size(phones,1), size(tmp,2));

fprintf(1, 'True #tmpl per phone: %d\n', n_tmpl_per_phone_real);

for ip = 1:length(phones)
    fprintf(1, 'phone %d...\n', ip);
    tpl_idx = 1;
    while tpl_idx <= n_tmpl_per_phone_real
        % this while loop is to avoid the case where some speaker
        % never speaked some phone in the corpus

        for ispk = 1:speaker_num
            trainlab_spk = trainlab(spk_index(ispk, :));
            traindata_spk = traindata(spk_index(ispk, :));

            for it = 1:nt_per_spk
                max_try = 200;
                for itry = 1:max_try
                    % find a random phone
                    ist = randsample(1:length(trainlab_spk), 1);
                    lab = trainlab_spk{ist};
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

                if length(idx) < 1
                    % maybe the speaker never say this phone
                    break;
                end
            
                fea_sentence = do_stack(traindata_spk{ist}, stack_num, use_delta);
                tmpl_v = fea_sentence(randsample(idx,1), :);
                tmpls_all((ip-1)*n_tmpl_per_phone_real + tpl_idx, :) = tmpl_v / norm(tmpl_v);
                tpl_idx = tpl_idx + 1;
                if tpl_idx > n_tmpl_per_phone_real
                    break
                end
            end
            if tpl_idx > n_tmpl_per_phone_real
                break
            end
        end
    end
end

assert(size(tmpls_all,1) == n_tmpl_per_phone_real*size(phones,1));

if balance_speaker
    profile = ['bspk-' profile];
end
if ~use_delta
    profile = ['nodelta-' profile];
end
if stack_num > 0
    profile = sprintf('stk%d-%s', stack_num, profile);
end
if raw_fbank
    profile = ['rawfb-' profile];
end

filename = sprintf('data/templates/fbank-tmpls-%s-%d.mat', profile, n_tmpl_per_phone);
n_tmpl_per_phone = n_tmpl_per_phone_real;
save(filename, '-v7.3', 'tmpls_all', 'n_tmpl_per_phone', 'use_delta', 'stack_num', 'raw_fbank');
