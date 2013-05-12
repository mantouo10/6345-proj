function fea_stack = do_stack(fea, Nstk, use_delta)

if ~exist('use_delta', 'var')
    use_delta = true;
end

if ~use_delta
    assert(size(fea,2) == 123);
    fea = fea(:, 1:41);
end

N = size(fea, 1);
fea = [repmat(fea(1,:), Nstk, 1); fea; repmat(fea(end,:), Nstk, 1)];
fea_dup = arrayfun(@(i) fea(i:N+i-1,:), 1:2*Nstk+1, 'UniformOutput', false);
fea_stack = cat(2, fea_dup{:});

end
