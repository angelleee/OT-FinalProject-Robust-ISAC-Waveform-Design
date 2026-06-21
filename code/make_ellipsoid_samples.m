function U_delta = make_ellipsoid_samples(eps_vec_deg, Nsample, boundary_only)
%MAKE_ELLIPSOID_SAMPLES Generate target angle errors from an ellipsoidal set.
%
% Uncertainty model:
%   delta = P u
%   P = diag(eps_1, eps_2, ..., eps_N)
%   ||u||_2 <= 1
%
% Input:
%   eps_vec_deg  : [eps_1, ..., eps_N] in degrees
%   Nsample      : total number of samples to generate, including center/axes
%   boundary_only: true -> boundary samples, false -> inside samples
%
% Output:
%   U_delta(q,n): angle error of target n for sample q.

    eps_vec_deg = eps_vec_deg(:).';
    Ntar = numel(eps_vec_deg);

    if all(eps_vec_deg == 0)
        U_delta = zeros(1, Ntar);
        return;
    end

    % Always include the center point u = 0.
    U_delta = zeros(1, Ntar);

    % Include axis boundary points u = +/- e_i.
    for i = 1:Ntar
        e = zeros(1, Ntar);
        e(i) = 1;
        U_delta = [U_delta;  eps_vec_deg .* e]; %#ok<AGROW>
        U_delta = [U_delta; -eps_vec_deg .* e]; %#ok<AGROW>
    end

    remaining = max(Nsample - size(U_delta, 1), 0);

    if remaining > 0
        U_norm = randn(remaining, Ntar);
        U_norm = U_norm ./ vecnorm(U_norm, 2, 2);

        if boundary_only
            radii = ones(remaining, 1);
        else
            radii = rand(remaining, 1).^(1/Ntar);
        end

        U_norm = U_norm .* radii;
        U_rand_delta = U_norm .* eps_vec_deg;
        U_delta = [U_delta; U_rand_delta]; %#ok<AGROW>
    end
end
