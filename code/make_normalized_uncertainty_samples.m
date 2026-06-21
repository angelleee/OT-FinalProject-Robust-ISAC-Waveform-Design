function U_norm = make_normalized_uncertainty_samples(Ntar, Nsample, boundary_only)
%MAKE_NORMALIZED_UNCERTAINTY_SAMPLES Generate dimensionless uncertainty samples.
%
% The normalized samples u are independent of the uncertainty radius.
% After generating u once, angle errors are obtained by
%   delta = P(epsilon) * u,
% where P(epsilon) = diag(eps_1, ..., eps_N).
%
% Input:
%   Ntar         : number of sensing targets
%   Nsample      : total number of samples to generate
%   boundary_only: true  -> samples on ||u||_2 = 1, plus the center point
%                  false -> samples inside ||u||_2 <= 1, plus axes/center
%
% Output:
%   U_norm(q,n): normalized uncertainty of target n for sample q.

    if Nsample <= 0
        U_norm = zeros(0, Ntar);
        return;
    end

    % Always include the center point u = 0.
    U_norm = zeros(1, Ntar);

    % Include axis points u = +/- e_i.
    for i = 1:Ntar
        e = zeros(1, Ntar);
        e(i) = 1;
        U_norm = [U_norm;  e]; %#ok<AGROW>
        U_norm = [U_norm; -e]; %#ok<AGROW>
    end

    remaining = max(Nsample - size(U_norm, 1), 0);

    if remaining > 0
        U_rand = randn(remaining, Ntar);
        U_rand = U_rand ./ vecnorm(U_rand, 2, 2);

        if boundary_only
            radii = ones(remaining, 1);
        else
            radii = rand(remaining, 1).^(1/Ntar);
        end

        U_rand = U_rand .* radii;
        U_norm = [U_norm; U_rand]; %#ok<AGROW>
    end

    % If Nsample is smaller than the deterministic center/axis samples,
    % keep exactly the requested number of rows.
    U_norm = U_norm(1:Nsample, :);
end
