function plot_beampattern_worst_case(params, d_worst, p_nominal, p_robust, ...
                                     alpha_nominal, alpha_robust, ...
                                     delta_worst, theta_true_worst, ...
                                     nominal_mse, robust_mse)
%PLOT_BEAMPATTERN_WORST_CASE Plot Experiment 3 results in one combined figure.
%
% Fig. 3 contains three panels:
%   (a) normalized overview,
%   (b) MSE-scaled patterns without per-curve normalization,
%   (c) squared-error curves used in the MSE.

    theta = params.theta_grid(:);
    d_worst = d_worst(:);
    p_nominal = real(p_nominal(:));
    p_robust = real(p_robust(:));

    d_scaled_nominal = alpha_nominal * d_worst;
    d_scaled_robust = alpha_robust * d_worst;

    err2_nominal = (p_nominal - d_scaled_nominal).^2;
    err2_robust = (p_robust - d_scaled_robust).^2;

    % Panel (a): normalized overview. A common scale is used for both
    % actual beampatterns, only for visual comparison.
    norm_scale = max([p_nominal; p_robust; 1e-12]);
    p_nominal_norm = p_nominal / norm_scale;
    p_robust_norm = p_robust / norm_scale;

    figure(3); clf;
    tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    %% (a) Normalized overview
    nexttile;
    plot(theta, d_worst, 'k--', 'LineWidth', 1.5); hold on;
    plot(theta, p_nominal_norm, 'LineWidth', 1.4);
    plot(theta, p_robust_norm, 'LineWidth', 1.4);
    add_true_target_lines(theta_true_worst);
    grid on;
    xlabel('Angle (deg)');
    ylabel('Norm. pattern');
    title('(a) Normalized overview');
    legend('Desired', 'Nominal', 'Robust', 'Location', 'best');

    %% (b) MSE-scaled patterns, no per-curve normalization
    nexttile;
    plot(theta, p_nominal, 'LineWidth', 1.4); hold on;
    plot(theta, d_scaled_nominal, '--', 'LineWidth', 1.4);
    plot(theta, p_robust, 'LineWidth', 1.4);
    plot(theta, d_scaled_robust, ':', 'LineWidth', 1.8);
    add_true_target_lines(theta_true_worst);
    grid on;
    xlabel('Angle (deg)');
    ylabel('Pattern power');
    title('(b) MSE-scaled patterns');
    legend('Nom p', 'Nom \alpha d', 'Rob p', 'Rob \alpha d', 'Location', 'best');

    %% (c) Squared-error curves used in MSE
    nexttile;
    plot(theta, err2_nominal, 'LineWidth', 1.4); hold on;
    plot(theta, err2_robust, 'LineWidth', 1.4);
    add_true_target_lines(theta_true_worst);
    grid on;
    xlabel('Angle (deg)');
    ylabel('Squared error');
    title('(c) Squared error');
    legend('Nominal', 'Robust', 'Location', 'best');

    sgtitle(sprintf('Exp. 3: delta=[%s] deg | MSE %.4g vs %.4g', ...
            strtrim(num2str(delta_worst, ' %.2f')), nominal_mse, robust_mse));
end

function add_true_target_lines(theta_true_worst)
%ADD_TRUE_TARGET_LINES Add vertical dotted lines at true target angles.
    yl = ylim;
    for n = 1:numel(theta_true_worst)
        plot([theta_true_worst(n), theta_true_worst(n)], yl, 'k:', ...
             'LineWidth', 0.9, 'HandleVisibility', 'off');
    end
    ylim(yl);
end
