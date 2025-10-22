clear; clc; close all;

% Set working directory to current file location
cd(fileparts(mfilename('fullpath')));

% Load fish trajectory data (top and side views)
fish_top = readmatrix('..\dataset\track\csv\G2.csv');
fish_side = readmatrix('..\dataset\track\csv\G1.csv');

% Compute center coordinates from paired points (e.g., left and right eye)
y_ref = (fish_top(:,5) + fish_top(:,8)) / 2;
x_ref = (fish_top(:,6) + fish_top(:,9)) / 2;
z_ref = (fish_side(:,6) + fish_side(:,9)) / 2;
y_nostril = fish_top(:,2);
x_nostril = fish_top(:,3);
z_nostril = fish_side(:,3);
y_tail = fish_top(:,23);
x_tail = fish_top(:,24);
z_tail = fish_side(:,24);

mm_per_pixel = 1.9e-2; % mm per pixel
FPS = 10;              % Frames per second
dt = 1 / FPS;          % Time step

%% speed
velocity_3d = sqrt(sum(diff([x_ref, y_ref, z_ref]).^2, 2)) * FPS * mm_per_pixel;
velocity_2d = sqrt(sum(diff([x_ref, y_ref]).^2, 2)) * FPS * mm_per_pixel;
figure; set(gcf, 'Position', [300, 600, 600, 200], 'Color', 'w');
plot((0:length(velocity_2d)-1)*dt, velocity_2d, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]); hold on;
plot((0:length(velocity_3d)-1)*dt, velocity_3d, 'LineWidth', 2, 'Color', [0.9 0.4 0.3]);
legend('2D Velocity', '3D Velocity', 'Location', 'best');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'LineWidth', 2);

%% acceleration
acceleration_3d = diff(velocity_3d) / dt;
acceleration_2d = diff(velocity_2d) / dt;
figure; set(gcf, 'Position', [300, 300, 600, 200], 'Color', 'w');
plot((0:length(acceleration_2d)-1)*dt, acceleration_2d, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]); hold on;
plot((0:length(acceleration_3d)-1)*dt, acceleration_3d, 'LineWidth', 2, 'Color', [0.9 0.4 0.3]);
legend('2D acceleration', '3D acceleration', 'Location', 'best');
xlabel('Time (s)');
ylabel('Acceleration (mm/s^2)');
set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'LineWidth', 2);

%% tail angle
% Compute 2D angles
vec_head_ref_2D = [x_nostril - x_ref, y_nostril - y_ref];
vec_tail_ref_2D = [x_nostril - x_tail, y_nostril - y_tail];
dot_product_2D = sum(vec_head_ref_2D .* vec_tail_ref_2D, 2);
norm_head_ref_2D = vecnorm(vec_head_ref_2D, 2, 2);
norm_tail_ref_2D = vecnorm(vec_tail_ref_2D, 2, 2);
angle_2D = acosd(dot_product_2D ./ (norm_head_ref_2D .* norm_tail_ref_2D));
% Compute 3D angles
vec_head_ref_3D = [x_nostril - x_ref, y_nostril - y_ref, z_nostril - z_ref];
vec_tail_ref_3D = [x_nostril - x_tail, y_nostril - y_tail, z_nostril - z_tail];
dot_product_3D = sum(vec_head_ref_3D .* vec_tail_ref_3D, 2);
norm_head_ref_3D = vecnorm(vec_head_ref_3D, 2, 2);
norm_tail_ref_3D = vecnorm(vec_tail_ref_3D, 2, 2);
angle_3D = acosd(dot_product_3D ./ (norm_head_ref_3D .* norm_tail_ref_3D));
% visulization
figure; set(gcf, 'Position', [1000, 600, 600, 200], 'Color', 'w');
plot((0:length(angle_2D)-1)*dt, angle_2D, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]); hold on;
plot((0:length(angle_3D)-1)*dt, angle_3D, 'LineWidth', 2, 'Color', [0.9 0.4 0.3]);
legend('2D tail angle', '3D tail angle', 'Location', 'best');
xlabel('Time (s)');
ylabel('Tail Angle (°)');
set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'LineWidth', 2);