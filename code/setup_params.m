function params = setup_params()
%SETUP_PARAMS Set all simulation parameters.

    params.Nt = 8;                       % # transmit antennas
    params.K = 3;                        % # communication users
    params.Mpsk = 4;                     % QPSK
    params.Pt = 10;                      % transmit power budget
    params.sigma2 = 1;                   % noise power

    params.Gamma_dB = 6;                 % CI SNR threshold in dB
    params.Gamma = 10^(params.Gamma_dB/10) * ones(params.K,1);

    params.theta_targets = [-20, 25];    % nominal target angles (deg)
    params.Ntar = numel(params.theta_targets);

    % Generalized diagonal uncertainty-shaping matrix:
    % P = diag(eps_1, eps_2, ..., eps_N)
    params.eps_vec_deg = [5, 3];         % one uncertainty bound per target (deg)

    params.theta_grid = -90:1:90;        % beampattern grid (deg)
    params.L = numel(params.theta_grid);
    params.beam_width_deg = 6;           % desired beam half width (deg)

    params.N_design_uncertainty = 20;    % robust-design uncertainty samples
    params.N_test_uncertainty = 3000;    % evaluation uncertainty samples
    params.N_randomization = 500;        % Gaussian randomization samples

    % Experiment 2: sweep the first target uncertainty radius epsilon_1.
    % The remaining target uncertainty radii keep the same relative ratio
    % as params.eps_vec_deg. For [5,3], this gives [eps, 0.6*eps].
    params.uncertainty_radius_list_deg = 0:1:7;
    params.uncertainty_shape = params.eps_vec_deg / max(params.eps_vec_deg);

    % Seeds for reproducible channel/symbols and uncertainty samples.
    params.main_seed = 7;
    params.uncertainty_design_seed = 17;
    params.uncertainty_test_seed = 29;

    % SDR tightness thresholds used during waveform recovery.
    params.rank_ratio_tol = 1 - 1e-4;
    params.coupling_residual_tol = 1e-4;
end
