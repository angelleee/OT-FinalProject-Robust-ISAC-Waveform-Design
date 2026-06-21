function plot_robust_vs_nominal_bars(nominal_eval, robust_eval)
%PLOT_ROBUST_VS_NOMINAL_BARS Plot sensing robustness comparison only.
%
% Fig. 1 in the previous version only showed WorstMSE, which is the
% rightmost bar group in the complete robustness comparison figure.
% Therefore, this version generates only one figure containing:
%   AverageMSE, P95MSE, and WorstMSE.

    figure;
    bar([nominal_eval.avg_mse, robust_eval.avg_mse; ...
         nominal_eval.p95_mse, robust_eval.p95_mse; ...
         nominal_eval.worst_mse, robust_eval.worst_mse]);

    set(gca, 'XTickLabel', {'Average MSE', '95% MSE', 'Worst-case MSE'});
    legend('Nominal Joint ISAC', 'Robust Joint ISAC', 'Location', 'northwest');
    ylabel('MSE');
    title('Sensing Robustness Comparison');
    grid on;
end
