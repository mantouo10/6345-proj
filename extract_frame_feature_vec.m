function fea = extract_frame_feature_vec(fbank, tmpl, n_tmpl_per_phone, n_bin, n_fband)

if n_fband == 1
    hist_bins = linspace(-1, 1, n_bin+1);

    % templates are already normalized
    fbank_norms = sqrt(sum(fbank.^2,2));
    fbank = bsxfun(@rdivide, fbank, fbank_norms);

    prod_all = fbank * tmpl';

    n_hist = size(tmpl,1)/n_tmpl_per_phone;
    fea = zeros(size(fbank,1), n_bin*n_hist);
    for i = 1:n_hist
        idx = (i-1)*n_tmpl_per_phone+1:i*n_tmpl_per_phone;
        the_hist = histc(prod_all(:,idx)', hist_bins) / n_tmpl_per_phone;
        fea(:, (i-1)*n_bin+1:i*n_bin) = the_hist(1:end-1,:)';
    end
else
    freq_bands = round(linspace(1, size(fbank,2), n_fband+1));
    fea0 = extract_frame_feature_vec(fbank(:,1:freq_bands(2)), tmpl(:,1:freq_bands(2)), ...
            n_tmpl_per_phone, n_bin, 1);
    fea = zeros(size(fea0,1), size(fea0,2)*n_fband);
    fea(:,1:size(fea0,2)) = fea0;
    for i = 2:n_fband
        ix_fband = freq_bands(i)+1:freq_bands(i+1);
        fea(:,(i-1)*size(fea0,2)+1:i*size(fea0,2)) = extract_frame_feature_vec(...
            fbank(:,ix_fband), tmpl(:,ix_fband), n_tmpl_per_phone, n_bin, 1);
    end
end

end
