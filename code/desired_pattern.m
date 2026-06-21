function d = desired_pattern(params, delta_theta)
%DESIRED_PATTERN Robust desired beampattern for one uncertainty realization.

    theta_grid = params.theta_grid(:);
    theta_targets = params.theta_targets(:).';
    beam_width = params.beam_width_deg;

    true_targets = theta_targets + delta_theta;
    d = zeros(numel(theta_grid), 1);

    for n = 1:numel(true_targets)
        diff_deg = angle_diff_deg(theta_grid, true_targets(n));
        d(abs(diff_deg) <= beam_width) = 1;
    end
end
