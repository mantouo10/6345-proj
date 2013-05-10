function fea = extract_frame_feature_vec(fbank, tmpl, n_tmpl_per_phone, n_bin)

% params
%n_bin = 4;%20;

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

end
