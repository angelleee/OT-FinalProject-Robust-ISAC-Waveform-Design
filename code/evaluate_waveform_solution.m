function eval = evaluate_waveform_solution(params, x, alpha_scale, U_test)
%EVALUATE_WAVEFORM_SOLUTION Evaluate recovered waveform performance.

    H = params.H;
    sigma2 = params.sigma2;

    y = H' * x;
    snr = abs(y).^2 / sigma2;
    sum_rate = sum(log2(1 + snr));

    ci_feasible = check_ci(params, x);

    R = x * x';
    p = beampattern_from_R(params, R);

    mse_samples = zeros(size(U_test,1), 1);
    for q = 1:size(U_test,1)
        d = desired_pattern(params, U_test(q,:));
        mse_samples(q) = mean((p(:) - alpha_scale * d(:)).^2);
    end

    d0 = desired_pattern(params, zeros(1, params.Ntar));
    nominal_mse = mean((p(:) - alpha_scale * d0(:)).^2);

    eval.sum_rate = sum_rate;
    eval.snr = snr;
    eval.ci_feasible = ci_feasible;
    eval.nominal_mse = nominal_mse;
    eval.avg_mse = mean(mse_samples);
    eval.p95_mse = prctile(mse_samples, 95);
    eval.worst_mse = max(mse_samples);
    eval.mse_samples = mse_samples;
    eval.power = norm(x)^2;
end
