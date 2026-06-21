Robust Angle-Uncertainty-Aware Joint ISAC MATLAB Package
=======================================================

Run:
  1. Add CVX to your MATLAB path and run cvx_setup.
  2. Open this folder in MATLAB.
  3. Run: main

main.m runs three experiments:

Experiment 1: Robust vs Nominal Joint ISAC
  - Fixed uncertainty matrix P = diag(params.eps_vec_deg).
  - Compares SumRate, NominalMSE, AverageMSE, P95MSE, WorstMSE, and CIFeasible.
  - Saves results to sim1_robust_vs_nominal_results.mat.
  - Plots the robustness comparison figure.

Experiment 2: Worst-case MSE versus uncertainty radius
  - Sweeps epsilon_1 = 0:1:7 degrees.
  - Uses P(epsilon) = diag(epsilon * params.uncertainty_shape).
  - For default params.eps_vec_deg = [5, 3], this gives [epsilon, 0.6*epsilon].
  - Reuses the same normalized design and test samples for every radius:
        delta_q(epsilon) = P(epsilon) * u_q.
  - Saves results to sim2_worst_mse_vs_uncertainty_radius_results.mat.
  - Plots WorstMSE versus epsilon_1.

Experiment 3: Beampattern/error visualization under worst-case angle error
  - Selects the test uncertainty sample with the largest nominal MSE.
  - Uses that same angle error to compare nominal and robust designs.
  - Saves results to sim3_beampattern_worst_case_results.mat.
  - Plots one combined Fig. 3 with three panels:
      (a) normalized overview,
      (b) MSE-scaled patterns without per-curve normalization,
      (c) squared-error curves used in MSE.

Important parameters are in setup_params.m:
  params.eps_vec_deg = [5, 3];
  params.uncertainty_radius_list_deg = 0:1:7;
  params.N_design_uncertainty = 20;
  params.N_test_uncertainty = 3000;
