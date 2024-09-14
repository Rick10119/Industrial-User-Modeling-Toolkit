%% Validate with Lu-2021 Data

% Refer to the paper "lu-2021-data-driven"
filename = "load_parameters_Lu_milp.xlsx";
load_parameter = xlsread(filename);

%% Load Related Parameters

% Energy consumption coefficients
e_np = load_parameter(:, [2, 4, 6]);

% Material production coefficients
g_np = load_parameter(:, [1, 3, 5]);

% Material maximum/minimum values (0), raw materials are essentially unlimited
S_max = load_parameter(:, 7);
S_max(end) = 400;

% Initial material values
S_0 = 0.5 * S_max;
S_0(end) = 0;

% Material target values (variation)
S_tar = zeros(size(S_max));
S_tar(end) = 15 * 24; % Bottleneck process needs to operate for 21 hours.

%% Market Prices and Other Parameters

% Read system energy price data
% Time slot length, 1 hour
day_price = 1; % Selected day
hour_init = 1; % Start from the first time slot of the day
NOFSLOTS = 24;

% Read prices for all days in the month (August)
Price_days = [];
for day_price = 1 : 31
    start_row = (day_price-1) * 24 + hour_init + 1; % Start row
    filename = 'rt_hrl_lmps_202208.xlsx';
    sheet = 'sheet1'; % Sheet
    xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % Range
    Price = xlsread(filename, sheet, xlRange); % Price data
    Price_days = [Price_days, Price];
end

clear Price filename sheet xlRange start_row hour_init day_price NOFSLOTS;

% Convert prices to $/kWh
Price_days = Price_days * 1e-3;
