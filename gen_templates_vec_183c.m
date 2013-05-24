n_tmpl_per_phone = 1; % 1 means taking average of all phones in that category
stack_num = 5;
n_phone = 183;

load data/fbank-invariance-features-bigarray-compact-debug.mat

tmp = do_stack(features_tr(1,:), stack_num, 1);
tmpls_all = zeros(n_tmpl_per_phone*n_phone, size(tmp,2));
tpl_idx = zeros(1, n_phone+1);

for ip = 1:n_phone
    fprintf(1, 'phone %d...\n', ip);
    idx_phone = find(trainlab == ip);
    if length(idx_phone) > n_tmpl_per_phone && n_tmpl_per_phone ~= 1
        rp = randperm(length(idx_phone));
        idx_phone = idx_phone(rp(1:n_tmpl_per_phone));
    end

    tpl_idx(ip+1) = tpl_idx(ip) + length(idx_phone);
    fea = do_stack(features_tr(idx_phone,:), stack_num, 1);
    fea = bsxfun(@rdivide, fea, sqrt(sum(fea.^2, 2)));
    if n_tmpl_per_phone == 1
        fea = mean(fea);
        tpl_idx(ip+1) = tpl_idx(ip)+1;
    end
    tmpls_all(tpl_idx(ip)+1:tpl_idx(ip+1),:) = fea;
end

tmpls_all = tmpls_all(1:tpl_idx(end),:);

profile = '183c';
if stack_num > 0
    profile = sprintf('stk%d-%s', stack_num, profile);
end

filename = sprintf('data/templates/fbank-tmpls-%s-%d.mat', profile, n_tmpl_per_phone);
save(filename, '-v7.3', 'tmpls_all', 'stack_num', 'tpl_idx');
