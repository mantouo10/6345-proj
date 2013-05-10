frames = [120 121 123 128 150];
%legends = cell(size(frames));
colors = 'rgbkcym';

figure;
subplot(1,2,1);
for i=1:length(frames)
    plot(1:size(features_tr,2),features_tr(frames(i),:)+(i-1)*0.3,colors(i));
    %legends{i} = sprintf('%d', trainlab(frames(i)));
    hold on;
end
legend(legends{:});

subplot(1,2,2);
for i=1:length(frames)
    plot(1:size(traindata{1},2), traindata{1}(frames(i),:)+(i-1)*3.2,colors(i));
    %legends{i} = sprintf('%d', trainlab{1}(frames(i)));
    hold on;
end
legend(legends{:});