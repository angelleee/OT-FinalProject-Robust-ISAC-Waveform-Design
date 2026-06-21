%% main.m
% Simulation 1: Robust vs Nominal Joint ISAC
% Simulation 2: Worst-case MSE versus uncertainty radius
% Simulation 3: Beampattern/error visualization under worst-case angle error
%
% SDR relaxation aligned with the derivation:
%   R = x*x^H  -->  R >= x*x^H
%   [R x; x^H 1] >= 0 by Schur complement
%
% Requirements:
%   - CVX installed and added to MATLAB path
%
% Run:
%   >> main

clear; clc; close all;

%% 1. Setup parameters
params = setup_params();
rng(params.main_seed);

%% 2. Generate channels, symbols, and steering matrices
params = generate_channel_and_symbols(params);
params.Agrid = build_steering_mats(params.Nt, params.theta_grid);

%% ============================================================
% Experiment 1: Robust vs Nominal comparison
% ============================================================

fprintf('==============================================\n');
fprintf('Experiment 1: Robust vs Nominal Joint ISAC\n');
fprintf('Gamma = %.2f dB\n', params.Gamma_dB);
fprintf('P = diag([');
fprintf(' %.2f', params.eps_vec_deg);
fprintf(' ]) degrees\n');
fprintf('Design uncertainty samples = %d\n', params.N_design_uncertainty);
fprintf('Test uncertainty samples   = %d\n', params.N_test_uncertainty);
fprintf('==============================================\n\n');

U_nominal_design = zeros(1, params.Ntar);

% Generate normalized uncertainty samples once, then scale them by P.
% This keeps the relative uncertainty directions fixed and changes only
% the uncertainty radius.
rng(params.uncertainty_design_seed);
U_design_norm = make_normalized_uncertainty_samples(params.Ntar, ...
                                                    params.N_design_uncertainty, true);

rng(params.uncertainty_test_seed);
U_test_norm = make_normalized_uncertainty_samples(params.Ntar, ...
                                                  params.N_test_uncertainty, false);

U_robust_design = scale_uncertainty_samples(U_design_norm, params.eps_vec_deg);
U_test = scale_uncertainty_samples(U_test_norm, params.eps_vec_deg);

fprintf('Solving Nominal Joint ISAC ... ');
nominal = solve_joint_isac_cvx(params, U_nominal_design, 'Nominal Joint ISAC');
nominal = recover_waveform(params, nominal, U_nominal_design, params.N_randomization);
nominal_eval = evaluate_waveform_solution(params, nominal.x_rec, nominal.alpha_scale_rec, U_test);
fprintf('done.\n');

fprintf('Solving Robust Joint ISAC  ... ');
robust = solve_joint_isac_cvx(params, U_robust_design, 'Robust Joint ISAC');
robust = recover_waveform(params, robust, U_robust_design, params.N_randomization);
robust_eval = evaluate_waveform_solution(params, robust.x_rec, robust.alpha_scale_rec, U_test);
fprintf('done.\n\n');

performanceTable = make_performance_table({nominal, robust}, ...
                                          {nominal_eval, robust_eval});

tightnessTable = make_sdr_tightness_table({nominal, robust});

fprintf('Recovered Waveform Performance\n');
fprintf('------------------------------------------------------------\n');
disp(performanceTable);

fprintf('SDR Tightness Check\n');
fprintf('------------------------------------------------------------\n');
disp(tightnessTable);

save('sim1_robust_vs_nominal_results.mat', ...
     'params', 'U_design_norm', 'U_test_norm', ...
     'U_nominal_design', 'U_robust_design', 'U_test', ...
     'nominal', 'robust', 'nominal_eval', 'robust_eval', ...
     'performanceTable', 'tightnessTable');

fprintf('Experiment 1 results saved to sim1_robust_vs_nominal_results.mat\n\n');

plot_robust_vs_nominal_bars(nominal_eval, robust_eval);

%% ============================================================
% Experiment 2: Worst-case MSE versus uncertainty radius
% ============================================================

fprintf('==============================================\n');
fprintf('Experiment 2: Worst-case MSE versus uncertainty radius\n');
fprintf('Uncertainty shape = [');
fprintf(' %.2f', params.uncertainty_shape);
fprintf(' ]\n');
fprintf('Swept epsilon_1 values = [');
fprintf(' %.2f', params.uncertainty_radius_list_deg);
fprintf(' ] degrees\n');
fprintf('==============================================\n\n');

radius_list = params.uncertainty_radius_list_deg(:);
num_radius = numel(radius_list);

sim2_eps_vec = zeros(num_radius, params.Ntar);
sim2_nominal_eval = cell(num_radius, 1);
sim2_robust_eval = cell(num_radius, 1);
sim2_robust_sol = cell(num_radius, 1);

for r_idx = 1:num_radius
    eps_radius = radius_list(r_idx);
    eps_vec = eps_radius * params.uncertainty_shape;
    sim2_eps_vec(r_idx, :) = eps_vec;

    fprintf('Radius %.2f deg, P = diag([', eps_radius);
    fprintf(' %.2f', eps_vec);
    fprintf(' ]) ... ');

    % Use the same normalized test samples for every radius.
    % Only P(epsilon) changes across the sweep.
    U_test_eps = scale_uncertainty_samples(U_test_norm, eps_vec);

    % The nominal design does not depend on the uncertainty radius.
    sim2_nominal_eval{r_idx} = evaluate_waveform_solution(params, nominal.x_rec, ...
                                                          nominal.alpha_scale_rec, U_test_eps);

    if eps_radius == 0
        % With zero uncertainty, the robust design reduces to the nominal design.
        sim2_robust_sol{r_idx} = nominal;
        sim2_robust_eval{r_idx} = sim2_nominal_eval{r_idx};
    elseif max(abs(eps_vec - params.eps_vec_deg)) < 1e-12
        % Reuse Experiment 1 robust result for the same uncertainty setting.
        sim2_robust_sol{r_idx} = robust;
        sim2_robust_eval{r_idx} = robust_eval;
    else
        % Use the same normalized design samples for every radius.
        U_robust_design_eps = scale_uncertainty_samples(U_design_norm, eps_vec);

        robust_eps = solve_joint_isac_cvx(params, U_robust_design_eps, 'Robust Joint ISAC');
        robust_eps = recover_waveform(params, robust_eps, U_robust_design_eps, params.N_randomization);
        robust_eps_eval = evaluate_waveform_solution(params, robust_eps.x_rec, ...
                                                     robust_eps.alpha_scale_rec, U_test_eps);

        sim2_robust_sol{r_idx} = robust_eps;
        sim2_robust_eval{r_idx} = robust_eps_eval;
    end

    fprintf('done.\n');
end

sweepTable = make_uncertainty_sweep_table(radius_list, sim2_eps_vec, ...
                                          sim2_nominal_eval, sim2_robust_eval);

fprintf('\nWorst-case MSE versus Uncertainty Radius\n');
fprintf('------------------------------------------------------------\n');
disp(sweepTable);

save('sim2_worst_mse_vs_uncertainty_radius_results.mat', ...
     'params', 'radius_list', 'sim2_eps_vec', ...
     'U_design_norm', 'U_test_norm', ...
     'sim2_nominal_eval', 'sim2_robust_eval', 'sim2_robust_sol', ...
     'sweepTable');

fprintf('Experiment 2 results saved to sim2_worst_mse_vs_uncertainty_radius_results.mat\n');

plot_worst_mse_vs_uncertainty(sweepTable);

%% ============================================================
% Experiment 3: Beampattern under worst-case angle error
% ============================================================

fprintf('\n==============================================\n');
fprintf('Experiment 3: Beampattern under worst-case angle error\n');
fprintf('Worst-case angle error is selected from the nominal waveform\n');
fprintf('over the Experiment 1 test uncertainty set.\n');
fprintf('==============================================\n\n');

% Select the uncertainty realization that gives the worst MSE for the
% nominal waveform in Experiment 1. The same angle error is then used to
% compare the nominal and robust beampatterns.
[~, worst_idx_nominal] = max(nominal_eval.mse_samples);
delta_worst = U_test(worst_idx_nominal, :);
theta_true_worst = params.theta_targets + delta_worst;

d_worst = desired_pattern(params, delta_worst);
p_nominal = beampattern_from_R(params, nominal.x_rec * nominal.x_rec');
p_robust = beampattern_from_R(params, robust.x_rec * robust.x_rec');

% These are the exact scaled desired patterns and squared-error curves
% used by the MSE computation. They are not normalized for visualization.
d_scaled_nominal = nominal.alpha_scale_rec * d_worst(:);
d_scaled_robust = robust.alpha_scale_rec * d_worst(:);
err2_nominal = (p_nominal(:) - d_scaled_nominal(:)).^2;
err2_robust = (p_robust(:) - d_scaled_robust(:)).^2;

nominal_worst_mse_at_delta = mean(err2_nominal);
robust_mse_at_nominal_worst_delta = mean(err2_robust);

fprintf('Worst-case sample index for nominal waveform: %d\n', worst_idx_nominal);
fprintf('Worst-case angle error delta = [');
fprintf(' %.4f', delta_worst);
fprintf(' ] degrees\n');
fprintf('True target angles = [');
fprintf(' %.4f', theta_true_worst);
fprintf(' ] degrees\n');
fprintf('Nominal MSE at this delta = %.6e\n', nominal_worst_mse_at_delta);
fprintf('Robust  MSE at this delta = %.6e\n\n', robust_mse_at_nominal_worst_delta);

exp3Table = table( ...
    worst_idx_nominal, ...
    string(mat2str(delta_worst, 4)), ...
    string(mat2str(theta_true_worst, 4)), ...
    nominal_worst_mse_at_delta, ...
    robust_mse_at_nominal_worst_delta, ...
    'VariableNames', {'WorstIndex', 'DeltaDeg', 'TrueTargetAnglesDeg', ...
                      'NominalMSE', 'RobustMSE'});

fprintf('Beampattern Worst-case Angle Error Summary\n');
fprintf('------------------------------------------------------------\n');
disp(exp3Table);

save('sim3_beampattern_worst_case_results.mat', ...
     'params', 'delta_worst', 'theta_true_worst', 'worst_idx_nominal', ...
     'd_worst', 'p_nominal', 'p_robust', ...
     'd_scaled_nominal', 'd_scaled_robust', ...
     'err2_nominal', 'err2_robust', ...
     'nominal_worst_mse_at_delta', 'robust_mse_at_nominal_worst_delta', ...
     'exp3Table');

fprintf('Experiment 3 results saved to sim3_beampattern_worst_case_results.mat\n');

plot_beampattern_worst_case(params, d_worst, p_nominal, p_robust, ...
                            nominal.alpha_scale_rec, robust.alpha_scale_rec, ...
                            delta_worst, theta_true_worst, ...
                            nominal_worst_mse_at_delta, ...
                            robust_mse_at_nominal_worst_delta);
