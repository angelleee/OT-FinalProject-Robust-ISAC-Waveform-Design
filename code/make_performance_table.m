function T = make_performance_table(sol_list, eval_list)
%MAKE_PERFORMANCE_TABLE Build the concise main result table.

    n = numel(sol_list);
    Method = strings(n,1);
    SumRate = zeros(n,1);
    NominalMSE = zeros(n,1);
    AverageMSE = zeros(n,1);
    P95MSE = zeros(n,1);
    WorstMSE = zeros(n,1);
    CIFeasible = false(n,1);

    for i = 1:n
        sol = sol_list{i};
        ev = eval_list{i};

        Method(i) = string(sol.method_name);
        SumRate(i) = ev.sum_rate;
        NominalMSE(i) = ev.nominal_mse;
        AverageMSE(i) = ev.avg_mse;
        P95MSE(i) = ev.p95_mse;
        WorstMSE(i) = ev.worst_mse;
        CIFeasible(i) = ev.ci_feasible;
    end

    T = table(Method, SumRate, NominalMSE, AverageMSE, P95MSE, WorstMSE, CIFeasible);
end
