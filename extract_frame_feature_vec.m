function fea = extract_frame_feature_vec(fbank, tmpl, n_tmpl_per_phone, n_bin, n_fband)
% n_bin could be
%  - a number: histogram pooling is used
%  - 'mean': mean pooling is used

if n_fband == 1
    % templates are already normalized
    fbank_norms = sqrt(sum(fbank.^2,2));
    fbank = bsxfun(@rdivide, fbank, fbank_norms);

    prod_all = fbank * tmpl';

    n_hist = size(tmpl,1)/n_tmpl_per_phone;
    if isnumeric(n_bin)
        hist_bins = linspace(-1, 1, n_bin+1);
        fea = zeros(size(fbank,1), n_bin*n_hist);
    elseif strcmp(n_bin, 'mean')
        fea = zeros(size(fbank,1), n_hist);
    end

    for i = 1:n_hist
        idx = (i-1)*n_tmpl_per_phone+1:i*n_tmpl_per_phone;
        if isnumeric(n_bin) % histogram pooling
            the_hist = histc(prod_all(:,idx)', hist_bins) / n_tmpl_per_phone;
            fea(:, (i-1)*n_bin+1:i*n_bin) = the_hist(1:end-1,:)';
        elseif strcmp(n_bin, 'mean')
            fea(:, i) = mean(prod_all(:,idx), 2);
        end
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
