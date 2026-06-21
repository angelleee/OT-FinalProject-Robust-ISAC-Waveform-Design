function plot_worst_mse_vs_uncertainty(sweepTable)
%PLOT_WORST_MSE_VS_UNCERTAINTY Plot Experiment 2 result.

    figure;
    plot(sweepTable.Epsilon1Deg, sweepTable.NominalWorstMSE, '-o', 'LineWidth', 1.5);
    hold on;
    plot(sweepTable.Epsilon1Deg, sweepTable.RobustWorstMSE, '-s', 'LineWidth', 1.5);
    hold off;

    xlabel('Uncertainty radius \epsilon_1 (degrees)');
    ylabel('Worst-case MSE');
    title('Worst-case MSE versus Uncertainty Radius');
    legend('Nominal Joint ISAC', 'Robust Joint ISAC', 'Location', 'northwest');
    grid on;
end
