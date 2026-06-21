function [best_x, best_alpha_scale, best_mse] = try_candidate(params, x, U_design, best_x, best_alpha_scale, best_mse)
%TRY_CANDIDATE Evaluate one waveform candidate for recovery.

    if isempty(x)
        return;
    end

    if norm(x)^2 > params.Pt * (1 + 1e-6)
        return;
    end

    if ~check_ci(params, x)
        return;
    end

    alpha_scale = best_alpha_for_waveform(params, x, U_design);
    mse = worst_mse_for_waveform(params, x, alpha_scale, U_design);

    if mse < best_mse
        best_mse = mse;
        best_x = x;
        best_alpha_scale = alpha_scale;
    end
end
