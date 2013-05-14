function fea = extract_frame_feature_fbank_debug(fbank, tmpl, fb_band)

% do nothing, just output fbank

w_time  = size(tmpl, 1);

n_frames = size(fbank, 1) - w_time + 1;

%fea = fbank(1:n_frames, :);
fea = fbank;

end
