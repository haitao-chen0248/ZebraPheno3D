clear; clc; close all;

% Set working directory to the current file location
cd(fileparts(mfilename('fullpath')));

% Load 3D fish trajectory data (top and side views)
fish_top = readmatrix('..\dataset\track\csv\G2.csv');
fish_side = readmatrix('..\dataset\track\csv\G1.csv');

% Extract anatomical keypoints (x, y from top view; z from side view)
head    = [fish_top(:,2),  fish_top(:,3),  fish_side(:,3)];
eye1    = [fish_top(:,5),  fish_top(:,6),  fish_side(:,6)];
eye2    = [fish_top(:,8),  fish_top(:,9),  fish_side(:,9)];
bladder = [fish_top(:,11), fish_top(:,12), fish_side(:,12)];
tail1   = [fish_top(:,14), fish_top(:,15), fish_side(:,15)];
tail2   = [fish_top(:,17), fish_top(:,18), fish_side(:,18)];
tail3   = [fish_top(:,20), fish_top(:,21), fish_side(:,21)];
tail4   = [fish_top(:,23), fish_top(:,24), fish_side(:,24)];

% Define colors for keypoints (normalized RGB values)
colors = [
    101,  0, 219;   % Purple
     68,106, 220;   % Blue
     53,189, 210;   % Cyan
    126,244, 217;   % Green
    184,244, 181;   % Yellow
    230,200, 135;   % Orange
    225,112,  75;   % Orange-red
    204,  2,   7    % Red
] / 255;

% Initialize figure
figure;
set(gcf, 'Color', 'w', 'Position', [100, 100, 640, 600]); % White background, larger size
hold on;
axis([-150, 150, -150, 150, -150, 150]); % Fixed axis limits
grid on;
box on;

% Customize axes
ax = gca; ax.LineWidth = 2;
set(ax, 'YDir', 'reverse'); % Invert Y-axis
set(ax, 'ZDir', 'reverse'); % Invert Z-axis
set(ax, 'XTick', linspace(-150, 150, 3), 'XTickLabel', []);
set(ax, 'YTick', linspace(-150, 150, 3), 'YTickLabel', []);
set(ax, 'ZTick', linspace(-150, 150, 3), 'ZTickLabel', []);
set(ax, 'XTickLabel', {'-3','0','3'});
set(ax, 'YTickLabel', {'3','0','-3'});
set(ax, 'ZTickLabel', {'3','0','-3'});
set(ax, 'FontWeight', 'bold', 'FontSize', 16);
xlabel('X (mm)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Y (mm)', 'FontSize', 16, 'FontWeight', 'bold');
zlabel('Z (mm)', 'FontSize', 16, 'FontWeight', 'bold');
view(40, 30); % 3D view angle

% Animation loop
for i = 1:size(head, 1)
    % Select current frame
    idx = i;

    % Assemble keypoint matrix
    P = [head(idx,:);
         eye1(idx,:);
         eye2(idx,:);
         bladder(idx,:);
         tail1(idx,:);
         tail2(idx,:);
         tail3(idx,:);
         tail4(idx,:)];

    % Normalize coordinates: align bladder as origin
    offset = P(4, :);  % Bladder as reference point
    P = P - offset;

    % Define connection order for skeleton lines
    lines = [
        1 2;  % head to eye1
        1 3;  % head to eye2
        2 4;  % eye1 to bladder
        3 4;  % eye2 to bladder
        4 5;  % bladder to tail1
        5 6;  % tail1 to tail2
        6 7;  % tail2 to tail3
        7 8   % tail3 to tail4
    ];

    % Draw skeleton lines
    for j = 1:size(lines, 1)
        plot3([P(lines(j,1),1), P(lines(j,2),1)], ...
              [P(lines(j,1),2), P(lines(j,2),2)], ...
              [P(lines(j,1),3), P(lines(j,2),3)], ...
              'k-', 'LineWidth', 5);
    end

    % Draw keypoints
    for j = 1:8
        scatter3(P(j,1), P(j,2), P(j,3), 180, colors(j,:), 'filled');
    end

    drawnow;
    cla; % Clear axes for next frame
end