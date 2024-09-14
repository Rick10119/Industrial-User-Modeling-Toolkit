%% Aggregated Variables and Constraints for LSTN across Multiple Factories
% Output: Constraints_primal

% Operating time of machines in different states
T_hnp = sdpvar(NOFFACTORIES, NOFPOINTS, NOFMACHINES, NOFINTERVALS, 'full');

% Energy consumption of machines
E_hn = sdpvar(NOFMACHINES, NOFINTERVALS, 'full');

% Material quantity (0 for initial time interval, set to 0, then 1-24 for end values of each time interval)
S_hn = sdpvar(NOFFACTORIES, NOFMACHINES, NOFINTERVALS + 1, 'full');

%% Constraints (see data_generate_parameters for parameter meanings)

Constraints_primal = [];

% Energy consumption decomposition constraint (2)
temp = reshape(sum(T_hnp .* repmat(permute(F_e_np, [1, 3, 2]), 1, 1, 1, NOFINTERVALS), NOFPOINTS, NOFMACHINES, NOFINTERVALS);
temp = reshape(sum(temp), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, E_hn == temp];

% Non-negative time constraint (3)
Constraints_primal = [Constraints_primal, -T_hnp <= 0];

% Feasibility of time constraint (4)
temp = permute(T_hnp, [2, 1, 3, 4]);
temp = reshape(sum(temp), NOFFACTORIES, NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, temp == ones(NOFFACTORIES, NOFMACHINES, NOFINTERVALS)];

% Material change constraints (5, 6, 7)
% Initial time interval, given initial values
Constraints_primal = [Constraints_primal, S_hn(:, :, 1) == F_S_0];
% Subsequent time intervals
temp = permute(T_hnp, [2, 1, 3, 4]);
temp = reshape(sum(temp .* repmat(permute(F_g_np, [3, 1, 2]), 1, 1, 1, NOFINTERVALS), NOFFACTORIES, NOFMACHINES, NOFINTERVALS);
% Material change Factory*Machine*Time interval
% Non-terminal intervals
Constraints_primal = [Constraints_primal, S_hn(:, 1:end-1, 2:end) - S_hn(:, 1:end-1, 1:end-1) - ...
    temp(:, 1:end-1, 1:end) + temp(:, 2:end, 1:end) == 0];
% Terminal intervals (note the dimension difference between P and S)
Constraints_primal = [Constraints_primal, S_hn(:, end, 2:end) - S_hn(:, end, 1:end-1) - ...
    temp(:, end, 1:end) == 0];

% Material storage constraints (can ignore at the beginning and end)
Constraints_primal = [Constraints_primal, -S_hn <= 0];

Constraints_primal = [Constraints_primal, S_hn <= repmat(F_S_max, 1, 1, NOFINTERVALS + 1)];

% Material target (end time interval)
Constraints_primal = [Constraints_primal, F_S_0 + F_S_tar - S_hn(:, :, end) <= 0];
