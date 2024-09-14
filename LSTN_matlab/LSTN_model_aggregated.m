%% LSTN聚合的多个工厂的变量和约束
% 输出： 约束 Constraints_primal

% 机器在各运行状态的运行时间
T_hnp = sdpvar(NOFFACTORIES, NOFPOINTS, NOFMACHINES, NOFINTERVALS, 'full');

% 机器的耗能
E_hn = sdpvar(NOFMACHINES, NOFINTERVALS, 'full');

% 物料的量（0时段为初始值，设为0，其后为1-24时段末的值）
S_hn = sdpvar(NOFFACTORIES, NOFMACHINES, NOFINTERVALS + 1, 'full');

%% 约束(参数含义见data_generate_parameters)

Constraints_primal = [];

% 耗能分解约束(2)
temp = reshape(sum(T_hnp .* repmat(permute(F_e_np, [1, 3, 2]), 1, 1, 1, NOFINTERVALS)), NOFPOINTS, NOFMACHINES, NOFINTERVALS);
temp = reshape(sum(temp), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, E_hn == temp];

% 时间非负约束(3)
Constraints_primal = [Constraints_primal, - T_hnp <= 0];
% 时间可行性约束(4)
temp = permute(T_hnp, [2, 1, 3, 4]);
temp = reshape(sum(temp),  NOFFACTORIES, NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, temp == ones(NOFFACTORIES, NOFMACHINES, NOFINTERVALS)];

% 物料变化约束(5, 6, 7)
% 第一个时段，给定初值
Constraints_primal = [Constraints_primal, S_hn(:, :, 1) == F_S_0];
% 后续时段
temp = permute(T_hnp, [2, 1, 3, 4]);
temp = reshape(sum(temp .* repmat(permute(F_g_np, [3, 1, 2]), 1, 1, 1, NOFINTERVALS)), NOFFACTORIES, NOFMACHINES, NOFINTERVALS);
% 物料变化 工厂*机器*时间段
% 非末环节
Constraints_primal = [Constraints_primal, S_hn(:, 1 : end-1, 2 : end) - S_hn(:, 1 : end-1, 1 : end - 1) - ...
    temp(:, 1 : end-1, 1 : end) + temp(:, 2 : end, 1 : end) == 0];
% 末环节(注意P和S的维度差1)
Constraints_primal = [Constraints_primal, S_hn(:, end, 2 : end) - S_hn(:, end, 1 : end-1) - ...
    temp(:, end, 1 : end) == 0];

% 物料存储约束(首尾可以不管)
Constraints_primal = [Constraints_primal, - S_hn <= 0];

Constraints_primal = [Constraints_primal, S_hn <= repmat(F_S_max, 1, 1, NOFINTERVALS + 1)];

% 物料目标（末时段）
Constraints_primal = [Constraints_primal, F_S_0 + F_S_tar - S_hn(:, :, end) <= 0];
