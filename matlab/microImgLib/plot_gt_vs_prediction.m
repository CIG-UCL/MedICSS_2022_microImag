function plot_gt_vs_prediction(gt, prediction, figTitle)

scatter(gt, prediction, 'SizeData', 1);
title(figTitle);
xlabel('Ground truth');
ylabel('Network prediction');
hold on, plot([ 0 1], [0 1], 'r-');
xlim([0 1]);
ylim([0 1]);
daspect([1 1 1]);
hold off