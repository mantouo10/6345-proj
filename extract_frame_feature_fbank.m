function fea = extract_frame_feature_fbank(fbank, tmpl, fb_band)

% params
n_bin = 8;%20;
n_freq_shift = 3;

n_phone = size(tmpl, 3);
n_band  = size(fb_band, 1);
w_time  = size(tmpl, 1);
w_freq  = size(tmpl, 2);

hist_bins = linspace(-1, 1, n_bin+1);

n_frames = size(fbank, 1) - w_time + 1;

fea = zeros(n_band, n_phone, size(tmpl,5), n_bin, n_frames);

for ifr = 1:n_frames
    fb_fr = fbank(ifr:ifr+w_time-1, :);

    for ib = 1:n_band
        fband = fb_band(ib,1):fb_band(ib,2);
        pool_size = floor((length(fband)-w_freq)/n_freq_shift) + 1;

        for ip = 1:n_phone
            for ipos = 1:size(tmpl,5)
                v_stat = zeros(pool_size, size(tmpl, 6));
                for itl = 1:size(tmpl, 6)
                    patch = tmpl(:,:,ip,ib,ipos,itl);
                    patch_norm = norm(patch, 'fro');
                    pool = zeros(1, pool_size);
                    for j=1:pool_size
                        idx = (j-1)*n_freq_shift+1;
                        raw = fb_fr(:, idx:idx+w_freq-1);
                        pool(j) = sum(sum(patch .* raw)) / (patch_norm*norm(raw,'fro'));
                    end
                    v_stat(:,itl) = pool;
                end

                the_hist = histc(v_stat(:), hist_bins) / numel(v_stat);
                fea(ib, ip, ipos, :, ifr) = the_hist(1:end-1);
            end
        end
    end
end

fea = reshape(fea, n_band*n_phone*size(tmpl,5)*n_bin, n_frames)';

end
