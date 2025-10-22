clear; clc; close all;

% Set working directory to current file location
cd(fileparts(mfilename('fullpath')));

% Load fish trajectory data (top and side views)
fish_top = readmatrix('..\dataset\track\csv\G2.csv');
fish_side = readmatrix('..\dataset\track\csv\G1.csv');

% Compute center coordinates from paired points (e.g., head and tail)
y = (fish_top(:,5) + fish_top(:,8)) / 2;
x = (fish_top(:,6) + fish_top(:,9)) / 2;
z = (fish_side(:,6) + fish_side(:,9)) / 2;

% Set axis minimum values and prepare time index
xmin = 81;
ymin = 42;
zmin = 38;
time = 1:length(x);
color_data = time(1:end-1); % Time index for line segments

% Plot settings
figure('Position', [700, 250, 500, 450]);
set(gcf, 'Color', 'w');               % White background
colormap(jet(length(x)));             % Use 'jet' colormap
hold on;
axis([xmin, xmin+420, ymin, ymin+420, zmin, zmin+420]); % Fixed axis limits
box on;
grid on;
clim([min(time) max(time)]);          % Set color scale limits

% Draw 3D trajectory line and scatter points
for i = 1:length(x)-1
    color_idx = time(i);
    cmap = jet(length(x));
    line([x(i), x(i+1)], [y(i), y(i+1)], [z(i), z(i+1)], ...
        'Color', cmap(color_idx, :), 'LineWidth', 2);
    scatter3(x(i+1), y(i+1), z(i+1), 20, time(i+1), 'filled');
end

% Customize axes
ax = gca;
set(ax, 'ZDir', 'reverse'); % Reverse Z-axis for correct view
set(ax, 'xtick', linspace(xmin, xmin+420, 5), 'xticklabel', []);
set(ax, 'ytick', linspace(ymin, ymin+420, 5), 'yticklabel', []);
set(ax, 'ztick', linspace(zmin, zmin+420, 5), 'zticklabel', []);
set(ax, 'XTickLabel', {'8','6','4','2','0'});
set(ax, 'YTickLabel', {'0','2','4','6','8'});
set(ax, 'ZTickLabel', {'8','6','4','2','0'});
set(ax, 'LineWidth', 2);   % Thicker axis lines
set(ax, 'FontWeight', 'bold', 'FontSize', 16);
xlabel('Y (mm)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('X (mm)', 'FontSize', 16, 'FontWeight', 'bold');
zlabel('Z (mm)', 'FontSize', 16, 'FontWeight', 'bold');
view(130, 30);               % Set 3D viewing angle