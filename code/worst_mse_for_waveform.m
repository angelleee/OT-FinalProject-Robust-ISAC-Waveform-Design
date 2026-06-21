function mse_worst = worst_mse_for_waveform(params, x, alpha_scale, U_set)
%WORST_MSE_FOR_WAVEFORM Worst MSE over a set of uncertainty samples.

    R = x * x';
    p = beampattern_from_R(params, R);
    mse_all = zeros(size(U_set,1), 1);

    for q = 1:size(U_set,1)
        d = desired_pattern(params, U_set(q,:));
        mse_all(q) = mean((p(:) - alpha_scale * d(:)).^2);
    end

    mse_worst = max(mse_all);
end
