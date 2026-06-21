function T = make_sdr_tightness_table(sol_list)
%MAKE_SDR_TIGHTNESS_TABLE Build a compact SDR tightness check table.

    n = numel(sol_list);
    Method = strings(n,1);
    SDRRankRatio = zeros(n,1);
    CouplingResidual = zeros(n,1);
    RecoveryGap = zeros(n,1);
    RecoveryMethod = strings(n,1);

    for i = 1:n
        sol = sol_list{i};
        Method(i) = string(sol.method_name);
        SDRRankRatio(i) = sol.rank_ratio;
        CouplingResidual(i) = sol.coupling_residual;
        RecoveryGap(i) = sol.recovery_gap;
        RecoveryMethod(i) = string(sol.recovery_method);
    end

    T = table(Method, SDRRankRatio, CouplingResidual, RecoveryGap, RecoveryMethod);
end
