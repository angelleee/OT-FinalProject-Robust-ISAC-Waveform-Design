function T = make_uncertainty_sweep_table(radius_list, eps_vec_list, nominal_eval_list, robust_eval_list)
%MAKE_UNCERTAINTY_SWEEP_TABLE Build Experiment 2 result table.

    n = numel(radius_list);

    Epsilon1Deg = zeros(n,1);
    Epsilon2Deg = zeros(n,1);
    NominalWorstMSE = zeros(n,1);
    RobustWorstMSE = zeros(n,1);
    NominalP95MSE = zeros(n,1);
    RobustP95MSE = zeros(n,1);
    NominalAverageMSE = zeros(n,1);
    RobustAverageMSE = zeros(n,1);
    NominalCIFeasible = false(n,1);
    RobustCIFeasible = false(n,1);

    for i = 1:n
        ne = nominal_eval_list{i};
        re = robust_eval_list{i};

        Epsilon1Deg(i) = radius_list(i);
        Epsilon2Deg(i) = eps_vec_list(i,2);
        NominalWorstMSE(i) = ne.worst_mse;
        RobustWorstMSE(i) = re.worst_mse;
        NominalP95MSE(i) = ne.p95_mse;
        RobustP95MSE(i) = re.p95_mse;
        NominalAverageMSE(i) = ne.avg_mse;
        RobustAverageMSE(i) = re.avg_mse;
        NominalCIFeasible(i) = ne.ci_feasible;
        RobustCIFeasible(i) = re.ci_feasible;
    end

    T = table(Epsilon1Deg, Epsilon2Deg, ...
              NominalWorstMSE, RobustWorstMSE, ...
              NominalP95MSE, RobustP95MSE, ...
              NominalAverageMSE, RobustAverageMSE, ...
              NominalCIFeasible, RobustCIFeasible);
end
