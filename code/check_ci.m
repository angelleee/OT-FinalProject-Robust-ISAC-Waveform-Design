function ok = check_ci(params, x)
%CHECK_CI Check whether the waveform satisfies all CI constraints.

    K = params.K;
    H = params.H;
    s = params.s;
    Gamma = params.Gamma;
    sigma2 = params.sigma2;
    Mpsk = params.Mpsk;

    phi = pi / Mpsk;
    tol = 1e-6;

    ok = true;
    for k = 1:K
        z_k = (H(:,k)' * x) * conj(s(k));
        gamma_margin = sqrt(Gamma(k) * sigma2);

        c1 = real(z_k) >= gamma_margin - tol;
        c2 = imag(z_k) <= (real(z_k) - gamma_margin) * tan(phi) + tol;
        c3 = -imag(z_k) <= (real(z_k) - gamma_margin) * tan(phi) + tol;

        if ~(c1 && c2 && c3)
            ok = false;
            return;
        end
    end
end
