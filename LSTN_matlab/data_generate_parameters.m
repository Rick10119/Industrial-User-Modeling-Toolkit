%% 生产工厂的参数（2000个）
clc;clear;
% 输入：工厂个数，原始参数, 参数波动范围
NOFFACTORIES = 80;
variation_range = [0.8, 0.4];
% 输出：各工厂的参数

% 读取价格(202208), 24 * 31 ($/kWh)
data_price;

% 取8月5号的数据
Price = Price_days(:, 5);

%% 读取数据

% 工厂参数
parameter_Lu_milp;
NOFMACHINES = 10;
NOFPOINTS = 3;
NOFINTERVALS = 24;
delta_t = 1;

%% 负荷的相关参数，具体意义见ipad
% 初始化
F_e_np = zeros(NOFFACTORIES, NOFMACHINES, NOFPOINTS);
F_g_np = zeros(NOFFACTORIES, NOFMACHINES, NOFPOINTS);
F_S_max = zeros(NOFFACTORIES, NOFMACHINES, 1);
F_S_tar = zeros(NOFFACTORIES, NOFMACHINES, 1);
F_S_0 = zeros(NOFFACTORIES, NOFMACHINES, 1);

% 参数分布
i_dx = 1;
while i_dx <= NOFFACTORIES
    parameter_Lu_milp;
    for j_dx = 1 : NOFMACHINES
        for k_dx = 1: NOFPOINTS
            F_e_np(i_dx, j_dx, k_dx) = round(e_np(j_dx, k_dx) * (variation_range(1) + variation_range(2) * rand));% variation_range = [0.5, 2];
            F_g_np(i_dx, j_dx, k_dx) = round(g_np(j_dx, k_dx) * (variation_range(1) + variation_range(2) * rand));
        end
        F_S_max(i_dx, j_dx) = round(S_max(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_tar(i_dx, j_dx) = round(S_tar(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_0(i_dx, j_dx) = round(S_0(j_dx) * (variation_range(1) + variation_range(2) * rand));
        F_S_0(i_dx, j_dx) = min(F_S_max(i_dx, j_dx), F_S_0(i_dx, j_dx));
    end
    F_S_max(i_dx, end) = 800;
    temp = permute(F_g_np, [1, 3, 2]);
    F_S_tar(i_dx, end) = min(max(temp(i_dx, :, :))) * 24;% 瓶颈环节需要工作24个小时。
    
    % 判断是否可行
    e_np = F_e_np(i_dx,:,:);e_np = reshape(e_np, 10, 3);
    g_np = F_g_np(i_dx,:,:);g_np = reshape(g_np, 10, 3);
    S_max = F_S_max(i_dx, :)';
    S_tar = F_S_tar(i_dx, :)';
    S_0 = F_S_0(i_dx, :)';
    
    load_primal_problem_milp;
    % 求解成功
    if sol.problem == 0
        i_dx = i_dx + 1;
    end
end
clear i_dx j_dx k_dx NOFINTERVALS delta_t Price


save("F_parameters_" + NOFFACTORIES + ".mat");

