function sol = solve_joint_isac_cvx(params, U_design, method_name)
%SOLVE_JOINT_ISAC_CVX Solve nominal or robust joint ISAC design by CVX.
%
% SDR relaxation used here is aligned with the derivation:
%   Original non-convex coupling: R = x*x^H
%   Relaxation:                 R >= x*x^H
%   Schur complement LMI:       [R x; x^H 1] >= 0

    Nt = params.Nt;
    K = params.K;
    L = params.L;
    H = params.H;
    s = params.s;
    Gamma = params.Gamma;
    sigma2 = params.sigma2;
    Mpsk = params.Mpsk;
    Pt = params.Pt;
    Agrid = params.Agrid;

    phi = pi / Mpsk;

    cvx_clear;
    cvx_begin sdp quiet
        variable R(Nt,Nt) hermitian semidefinite
        variable x(Nt) complex
        variable alpha_scale nonnegative
        variable tau nonnegative
        expressions p(L)

        for l = 1:L
            p(l) = real(trace(Agrid(:,:,l) * R));
        end

        minimize(tau)
        subject to
            % Power constraint.
            real(trace(R)) <= Pt;

            % SDR coupling constraint:
            %   R >= x*x^H
            % represented as the Schur-complement LMI
            %   [R x; x^H 1] >= 0.
            [R, x; x', 1] == hermitian_semidefinite(Nt+1);

            % Constructive interference constraints.
            for k = 1:K
                z_k = (H(:,k)' * x) * conj(s(k));
                gamma_margin = sqrt(Gamma(k) * sigma2);

                real(z_k) >= gamma_margin;
                imag(z_k) <= (real(z_k) - gamma_margin) * tan(phi);
               -imag(z_k) <= (real(z_k) - gamma_margin) * tan(phi);
            end

            % Sensing beampattern MSE constraints.
            for q = 1:size(U_design,1)
                d = desired_pattern(params, U_design(q,:));
                sum_square(p - alpha_scale * d(:)) <= L * tau;
            end
    cvx_end

    if ~(strcmp(cvx_status, 'Solved') || strcmp(cvx_status, 'Inaccurate/Solved'))
        error('%s CVX failed. Status: %s. Try reducing Gamma_dB or changing parameters.', method_name, cvx_status);
    end

    R = full(R);
    R = (R + R') / 2;
    x = full(x);

    eigvals = sort(real(eig(R)), 'descend');
    eigvals = max(eigvals, 0);
    rank_ratio = eigvals(1) / max(sum(eigvals), 1e-12);

    coupling_residual = norm(R - x*x', 'fro') / max(norm(R, 'fro'), 1e-12);

    sol.method_name = method_name;
    sol.R_sdr = R;
    sol.x_cvx = x;
    sol.alpha_scale_sdr = full(alpha_scale);
    sol.tau_sdr = full(tau);
    sol.cvx_status = cvx_status;
    sol.rank_ratio = rank_ratio;
    sol.coupling_residual = coupling_residual;
end
