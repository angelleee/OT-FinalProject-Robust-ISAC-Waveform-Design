function p = beampattern_from_R(params, R)
%BEAMPATTERN_FROM_R Compute actual transmit beampattern on the angle grid.

    L = params.L;
    Agrid = params.Agrid;
    p = zeros(L,1);

    for l = 1:L
        p(l) = real(trace(Agrid(:,:,l) * R));
    end

    p = max(p, 0);
end
