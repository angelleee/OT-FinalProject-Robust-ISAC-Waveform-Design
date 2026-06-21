function U_delta = scale_uncertainty_samples(U_norm, eps_vec_deg)
%SCALE_UNCERTAINTY_SAMPLES Convert normalized samples to angle errors.
%
%   delta_q = P * u_q,  P = diag(eps_1, ..., eps_N)
%
% Input:
%   U_norm(q,n)  : normalized uncertainty samples u_q
%   eps_vec_deg  : [eps_1, ..., eps_N] in degrees
%
% Output:
%   U_delta(q,n) : angle-error samples in degrees

    eps_vec_deg = eps_vec_deg(:).';
    U_delta = U_norm .* eps_vec_deg;
end
