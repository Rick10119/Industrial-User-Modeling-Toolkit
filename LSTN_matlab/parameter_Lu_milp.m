%% 用Lu-2021的数据来验证

% 见论文lu-2021-data-driven
filename = "load_parameters_Lu_milp.xlsx";
load_parameter = xlsread(filename);

%% 负荷的相关参数，具体意义见ipad

% 能量消耗系数
e_np =  load_parameter(:, [2, 4, 6]);

% 物料生产系数
g_np =  load_parameter(:, [1, 3, 5]);

% 物料最大值/最小值(0), 原材料基本不限制
S_max = load_parameter(:, 7);
S_max(end) = 400;

% 物料初始值
S_0 = 0.5 * S_max;
S_0(end) = 0;

% 物料目标值（变化量）
S_tar = zeros(size(S_max));
S_tar(end) = 15 * 24;% 瓶颈环节需要工作21个小时。

%% 市场价格和其他参数
% 读取系统能量价格数据
% 时段长度，1小时
day_price = 1;% 所选择的天数
hour_init = 1; % 从这天的第一个时段开始
NOFSLOTS = 24;

% 直接读取这个月的所有天的价格(8月)
Price_days = [];
for day_price = 1 : 31

start_row = (day_price-1) * 24 + hour_init + 1;% 开始的行s
filename = 'rt_hrl_lmps_202208.xlsx';
sheet = 'sheet1'; % 所在表单
xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % 范围
Price = xlsread(filename, sheet, xlRange);% 容量价格、里程价格
Price_days = [Price_days, Price];

end
clear Price filename sheet xlRange start_row hour_init day_price NOFSLOTS 

% 价格转化为 $/kWh
Price_days = Price_days * 1e-3;


