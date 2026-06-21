function alpha_scale = best_alpha_for_waveform(params, x, U_set)
%BEST_ALPHA_FOR_WAVEFORM Least-squares scaling factor for a fixed waveform.

    R = x * x';
    p = beampattern_from_R(params, R);

    numerator = 0;
    denominator = 0;

    for q = 1:size(U_set,1)
        d = desired_pattern(params, U_set(q,:));
        numerator = numerator + d(:)' * p(:);
        denominator = denominator + d(:)' * d(:);
    end

    if denominator < 1e-12
        alpha_scale = 0;
    else
        alpha_scale = max(real(numerator / denominator), 0);
    end
end
