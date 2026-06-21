function params = generate_channel_and_symbols(params)
%GENERATE_CHANNEL_AND_SYMBOLS Generate user channels and PSK symbols.

    params.H = (randn(params.Nt, params.K) + 1j*randn(params.Nt, params.K)) / sqrt(2);

    sym_idx = randi([0, params.Mpsk-1], params.K, 1);
    params.s = exp(1j * 2*pi*sym_idx / params.Mpsk);
end
