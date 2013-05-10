% generate random templates
%phones = {'iy', 'f'};
phones = {'ih', 'uh', 'ae', 'aa', 'ah', 's', 'pcl', 'p', 'gcl', 'g', 'hh'};
tmpl_t_size = 15;
tmpl_f_size = 40;

n_pos_per_phone = 4;
n_tmpl_per_pos = 15;

tmpls_all = zeros(tmpl_f_size,tmpl_t_size,length(phones),n_pos_per_phone,n_tmpl_per_pos);

for ip = 1:length(phones)
    fprintf(1, 'Extracting templates from %s...\n', phones{ip});
    for ippp = 1:n_pos_per_phone
        ixf_t = rand();
        ixf_f = rand();
        tmpls = zeros(tmpl_f_size,tmpl_t_size,n_tmpl_per_pos);
        [spec,seed] = get_phone(phones{ip});
        for itpp = 1:n_tmpl_per_pos
            [spec,seed] = get_phone(seed);
            while size(spec,2) < tmpl_t_size + 3
                [spec,seed] = get_phone(seed);
            end
            ix_t = floor((size(spec,2)-tmpl_t_size)*ixf_t)+1;
            ix_f = floor((size(spec,1)-tmpl_f_size)*ixf_f)+1;
            tmpls(:,:,itpp) = spec(ix_f:ix_f+tmpl_f_size-1,ix_t:ix_t+tmpl_t_size-1);
            tmpls_all(:,:,ip,ippp,itpp) = tmpls(:,:,itpp);
        end

        fn = sprintf('data/templates/%d-%d-%s-%d.mat', tmpl_t_size, tmpl_f_size, phones{ip}, ippp);
        save(fn, 'tmpls', 'ixf_t', 'ixf_f');
    end
end

save(sprintf('data/templates/%d-%d-all.mat', tmpl_t_size, tmpl_f_size), 'tmpls_all', 'phones');
