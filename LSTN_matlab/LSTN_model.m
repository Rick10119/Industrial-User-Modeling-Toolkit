%% Validate with Lu-2021 Data for LSTN

% Input: 24h electricity price, factory parameters, NOFPOINTS, NOFMACHINES, NOFINTERVALS
%% Read Data

% Factory parameters
parameter_Lu_milp;
NOFMACHINES = 10;
NOFPOINTS = 3;

E_intervals = [];
Cost_intervals = [];

delta_t = 1;
% Number of time intervals
NOFINTERVALS = 24;

idx_day = 1;
Price = Price_days(:, idx_day);

%% Variable Setup

% Operating time of machines in different states
T_hnp = sdpvar(NOFPOINTS, NOFMACHINES, NOFINTERVALS, 'full');

% Energy consumption of machines
E_hn = sdpvar(NOFMACHINES, NOFINTERVALS, 'full');

% Material quantity (0 for initial time interval, set to 0, then 1-24 for end values of each time interval)
S_hn = sdpvar(NOFMACHINES, NOFINTERVALS + 1, 'full');

%% Constraints
Constraints_primal = [];

% Energy consumption decomposition constraint (2)
temp = reshape(sum(T_hnp .* repmat(e_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, E_hn == temp];

% Non-negative time constraint (3)
Constraints_primal = [Constraints_primal, -T_hnp <= 0];

% Feasibility of time constraint (4)
temp = reshape(sum(T_hnp), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, temp == ones(NOFMACHINES, NOFINTERVALS)];

% Material change constraints (5, 6, 7)
% Initial time interval, given initial values
Constraints_primal = [Constraints_primal, S_hn(:, 1) == S_0];
% Subsequent time intervals
temp = reshape(sum(T_hnp .* repmat(g_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
% Non-terminal intervals
Constraints_primal = [Constraints_primal, S_hn(1:end-1, 2:end) - S_hn(1:end-1, 1:end-1) - ...
    temp(1:end-1, 1:end) + temp(2:end, 1:end) == 0];
% Terminal intervals (note the dimension difference between P and S)
Constraints_primal = [Constraints_primal, S_hn(end, 2:end) - S_hn(end, 1:end-1) - ...
    temp(end, 1:end) == 0];

% Material storage constraints (can ignore at the beginning and end)
Constraints_primal = [Constraints_primal, -S_hn <= 0];

Constraints_primal = [Constraints_primal, S_hn <= repmat(S_max, 1, NOFINTERVALS + 1)];

% Material target (end time interval)
Constraints_primal = [Constraints_primal, S_0 + S_tar - S_hn(:, end) <= 0];

%% Objective Function
Z_primal = sum(E_hn) * Price;

%% Solve
ops = sdpsettings('debug', 1, 'solver', 'CPLEX');

sol = optimize(Constraints_primal, Z_primal, ops);

%% Calculate energy usage for each hour
E_val = ones(1, NOFMACHINES) * value(E_hn);
E_val = ones(1, 1/delta_t) * reshape(E_val', 1/delta_t, 24);
% plot(E_val);
