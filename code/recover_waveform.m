function sol = recover_waveform(params, sol, U_design, N_randomization)
%RECOVER_WAVEFORM Recover a feasible waveform from the relaxed SDP solution.
%
% Step 1: CVX jointly solves R* and x*.
% Step 2: Check whether the relaxation is tight:
%           rank_ratio close to 1 and R* approximately equal to x*x^H.
% Step 3: If tight, directly use x*. Otherwise, apply Gaussian randomization
%         from R* and select the best feasible waveform.

    is_tight = (sol.rank_ratio >= params.rank_ratio_tol) && ...
               (sol.coupling_residual <= params.coupling_residual_tol) && ...
               check_ci(params, sol.x_cvx);

    if is_tight
        sol.x_rec = sol.x_cvx;
        sol.alpha_scale_rec = sol.alpha_scale_sdr;
        sol.rec_design_worst_mse = worst_mse_for_waveform(params, sol.x_rec, ...
                                                          sol.alpha_scale_rec, U_design);
        sol.recovery_method = 'Direct optimized x';
        sol.recovery_gap = (sol.rec_design_worst_mse - sol.tau_sdr) / max(sol.tau_sdr, 1e-12);
        return;
    end

    R = sol.R_sdr;
    Nt = params.Nt;
    Pt = params.Pt;

    best_x = [];
    best_alpha_scale = [];
    best_mse = inf;

    % Candidate 1: CVX x.
    x0 = sol.x_cvx;
    [best_x, best_alpha_scale, best_mse] = try_candidate(params, x0, U_design, ...
                                                         best_x, best_alpha_scale, best_mse);

    % Candidate 2: full-power scaled CVX x.
    if norm(x0) > 1e-12
        x_scaled = sqrt(Pt) * x0 / norm(x0);
        [best_x, best_alpha_scale, best_mse] = try_candidate(params, x_scaled, U_design, ...
                                                             best_x, best_alpha_scale, best_mse);
    end

    % Candidate 3: Gaussian randomization from R.
    [V,D] = eig((R + R') / 2);
    d = max(real(diag(D)), 0);
    Rsqrt = V * diag(sqrt(d));

    for n = 1:N_randomization
        g = (randn(Nt,1) + 1j*randn(Nt,1)) / sqrt(2);
        x_rand = Rsqrt * g;
        if norm(x_rand) > 1e-12
            x_rand = sqrt(Pt) * x_rand / norm(x_rand);
        end

        [best_x, best_alpha_scale, best_mse] = try_candidate(params, x_rand, U_design, ...
                                                             best_x, best_alpha_scale, best_mse);
    end

    if isempty(best_x)
        warning('No CI-feasible randomized waveform found. Using CVX x directly.');
        best_x = sol.x_cvx;
        best_alpha_scale = best_alpha_for_waveform(params, best_x, U_design);
        best_mse = worst_mse_for_waveform(params, best_x, best_alpha_scale, U_design);
    end

    sol.x_rec = best_x;
    sol.alpha_scale_rec = best_alpha_scale;
    sol.rec_design_worst_mse = best_mse;
    sol.recovery_method = 'Gaussian randomization';
    sol.recovery_gap = (sol.rec_design_worst_mse - sol.tau_sdr) / max(sol.tau_sdr, 1e-12);
end
