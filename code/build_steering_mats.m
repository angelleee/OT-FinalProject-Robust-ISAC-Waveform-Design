function Agrid = build_steering_mats(Nt, theta_grid)
%BUILD_STEERING_MATS Build A(theta)=a(theta)a(theta)^H over the angle grid.

    L = numel(theta_grid);
    Agrid = zeros(Nt, Nt, L);

    for l = 1:L
        a = steering_vector(Nt, theta_grid(l));
        Agrid(:,:,l) = a * a';
    end
end
