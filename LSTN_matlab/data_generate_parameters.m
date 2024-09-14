%% Production Factory Parameters (2000 in total)
clc; clear;

% Input: Number of factories, original parameters, parameter variation range
NOFFACTORIES = 80;
variation_range = [0.8, 0.4];

% Output: Parameters for each factory

% Read prices (202208), 24 * 31 ($/kWh)
data_price;

% Select data for August 5th
Price = Price_days(:, 5);

%% Read Data

% Factory parameters
parameter_Lu_milp;
NOFMACHINES = 10;
NOFPOINTS = 3;
NOFINTERVALS = 24;
delta_t = 1;

%% Load Related Parameters
% Initialization
F_e_np = zeros(NOFFACTORIES, NOFMACHINES, NOFPOINTS);
F_g_np = zeros(NOFFACTORIES, NOFMACHINES, NOFPOINTS);
F_S_max = zeros(NOFFACTORIES, NOFMACHINES, 1);
F_S_tar = zeros(NOFFACTORIES, NOFMACHINES, 1);
F_S_0 = zeros(NOFFACTORIES, NOFMACHINES, 1);

% Parameter distribution
i_dx = 1;
while i_dx <= NOFFACTORIES
    parameter_Lu_milp;
    for j_dx = 1 : NOFMACHINES
        for k_dx = 1: NOFPOINTS
            F_e_np(i_dx, j_dx, k_dx) = round(e_np(j_dx, k_dx) * (variation_range(1) + variation_range(2) * rand)); % variation_range = [0.5, 2];
            F_g_np(i_dx, j_dx, k_dx) = round(g_np(j_dx, k_dx) * (variation_range(1) + variation_range(2) * rand));
        end
        F_S_max(i_dx, j_dx) = round(S_max(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_tar(i_dx, j_dx) = round(S_tar(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_0(i_dx, j_dx) = round(S_0(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_0(i_dx, j_dx) = min(F_S_max(i_dx, j_dx), F_S_0(i_dx, j_dx));
    end
    F_S_max(i_dx, end) = 800;
    temp = permute(F_g_np, [1, 3, 2]);
    F_S_tar(i_dx, end) = min(max(temp(i_dx, :, :))) * 24; % Bottleneck process needs to operate for 24 hours.

    % Check feasibility
    e_np = F_e_np(i_dx,:,:); e_np = reshape(e_np, 10, 3);
    g_np = F_g_np(i_dx,:,:); g_np = reshape(g_np, 10, 3);
    S_max = F_S_max(i_dx, :)';
    S_tar = F_S_tar(i_dx, :)';
    S_0 = F_S_0(i_dx, :)';

    load_primal_problem_milp;
    
    % Solution found
    if sol.problem == 0
        i_dx = i_dx + 1;
    end
end

clear i_dx j_dx k_dx NOFINTERVALS delta_t Price

save("F_parameters_" + NOFFACTORIES + ".mat");
