function fea = extract_frame_feature2(spec, tmpl)

% params
n_freq_bands = 4;  % frequency bands
n_freq_shift = 6;  % shift when pooling over frequency
n_time_shift = 3;  % shift for feature extraction
n_bin = 16;        % probability histogram precision

n_phone = size(tmpl, 3);
w_freq = size(tmpl, 1);
w_time = size(tmpl, 2);
hist_bins = linspace(-1,1,n_bin+1);
hist_bins = hist_bins(1:end-1);

n_frames = floor((size(spec, 2) - w_time)/n_time_shift) + 1;
fea = zeros(n_freq_bands*n_phone*size(tmpl,4)*n_bin, n_frames);
freq_bands = round(linspace(0, size(spec,1), n_freq_bands+1));

for ifr = 1:n_frames
    idx = (ifr-1)*n_time_shift + 1;
    spec_fr = spec(:, idx:idx+w_time-1);
    for ib = 1:n_freq_bands
        fband = freq_bands(ib)+1:freq_bands(ib+1);
        pool_size = floor((length(fband)-w_freq)/n_freq_shift)+1;

        fea_fr = zeros(n_bin, size(tmpl,4), n_phone);
        for ip = 1:n_phone
            for ipos = 1:size(tmpl, 4)
                v_stat = zeros(pool_size, size(tmpl, 5));
                for itl = 1:size(tmpl, 5)
                    patch = tmpl(:,:,ip, ipos, itl);
                    patch_norm = norm(patch, 'fro');

                    pool = zeros(1, pool_size);
                    for j = 1:pool_size
                        idx = (j-1)*n_freq_shift+1;
                        raw = spec_fr(idx:idx+w_freq-1,:);
                        pool(j) = sum(sum(patch .* raw)) / (patch_norm * norm(raw, 'fro'));
                    end
                    v_stat(:,itl) = pool;
                end
                fea_fr(:,ipos,ip) = histc(v_stat(:), hist_bins)/numel(v_stat);
            end
        end
        fea((ib-1)*numel(fea_fr)+1:ib*numel(fea_fr), ifr) = fea_fr(:);
    end
end

end
