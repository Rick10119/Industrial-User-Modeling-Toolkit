%% 用Lu-2021的数据来验，LSTN

% 输入：24h电价，工厂参数，NOFPOINTS, NOFMACHINES, NOFINTERVALS
%% 读取数据

% 工厂参数
parameter_Lu_milp;
NOFMACHINES = 10;
NOFPOINTS = 3;


E_intervals = [];
Cost_intervals = [];

delta_t = 1;
% 时间区间数量
NOFINTERVALS = 24;

idx_day = 1;
Price = Price_days(:, idx_day);
%% 变量设置

% 机器在各运行状态的运行时间
T_hnp = sdpvar(NOFPOINTS, NOFMACHINES, NOFINTERVALS, 'full');

% 机器的耗能
E_hn = sdpvar(NOFMACHINES, NOFINTERVALS, 'full');

% 物料的量（0时段为初始值，设为0，其后为1-24时段末的值）
S_hn = sdpvar(NOFMACHINES, NOFINTERVALS + 1, 'full');

%% 约束
Constraints_primal = [];

% 耗能分解约束(2)
temp = reshape(sum(T_hnp .* repmat(e_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, E_hn == temp];

% 时间非负约束(3)
Constraints_primal = [Constraints_primal, - T_hnp <= 0];
% 时间可行性约束(4)
temp = reshape(sum(T_hnp),  NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, temp == ones(NOFMACHINES, NOFINTERVALS)];

% 物料变化约束(5, 6, 7)
% 第一个时段，给定初值
Constraints_primal = [Constraints_primal, S_hn(:, 1) == S_0];
% 后续时段
temp = reshape(sum(T_hnp .* repmat(g_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
% 非末环节
Constraints_primal = [Constraints_primal, S_hn(1 : end-1, 2 : end) - S_hn(1 : end-1, 1 : end - 1) - ...
    temp(1 : end-1, 1 : end) + temp(2 : end, 1 : end) == 0];
% 末环节(注意P和S的维度差1)
Constraints_primal = [Constraints_primal, S_hn(end, 2 : end) - S_hn(end, 1 : end-1) - ...
    temp(end, 1 : end) == 0];

% 物料存储约束(首尾可以不管)
Constraints_primal = [Constraints_primal, - S_hn <= 0];

Constraints_primal = [Constraints_primal, S_hn <= repmat(S_max, 1, NOFINTERVALS + 1)];

% 物料目标（末时段）
Constraints_primal = [Constraints_primal, S_0 + S_tar - S_hn(:, end) <= 0];


%% 目标函数
Z_primal = sum(E_hn) * Price;

%% solve
ops = sdpsettings('debug',1,'solver','CPLEX');

sol = optimize(Constraints_primal, Z_primal, ops)


%% 统计每个小时的用能
E_val = ones(1, NOFMACHINES) * value(E_hn);
E_val = ones(1, 1/delta_t) * reshape(E_val', 1/delta_t, 24);
% plot(E_val);
