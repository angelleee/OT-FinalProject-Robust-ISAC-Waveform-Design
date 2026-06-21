function a = steering_vector(Nt, theta_deg)
%STEERING_VECTOR Half-wavelength ULA steering vector.

    n = (0:Nt-1).';
    theta_rad = deg2rad(theta_deg);
    a = exp(1j*pi*n*sin(theta_rad)) / sqrt(Nt);
end
