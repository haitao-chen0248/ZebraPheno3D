% Clear workspace and command window
clear; close all;

% Path to the folder containing CSV files
folderPath = './';

% Get the list of CSV files
fileList = dir(fullfile(folderPath, '*.csv'));

% Initialize variables for storing categorized file names
side_view_files = {}; % To store side view files and their info
top_view_files = {}; % To store side view files and their info

% Parameters
mm_per_pixel = 9.51e-3*2; % mm per pixel
FPS = 20;              % Frames per second

% Classify files based on naming convention
for i = 1:length(fileList)
    fileName = fileList(i).name;
    if contains(fileName, 'well')
        % Extract well identifier (e.g., A1, B3, etc.)
        wellID = regexp(fileName, 'well_([A-H]\d{1,2})', 'tokens', 'once');
        if ~isempty(wellID)
            row = wellID{1}(1); % Extract row (A-H)
            col = str2double(wellID{1}(2:end)); % Extract column (1-12)
            if mod(col, 2) == 1            
                side_view_files{end+1} = {fileName, row, col}; % Store file info
            else                
                top_view_files{end+1} = {fileName, row, col}; % Store file info
            end
        end
    end
end

% Sort
rows1 = cellfun(@(x) x{2}, top_view_files, 'UniformOutput', false);  % Extract rows (letters)
cols1 = cellfun(@(x) x{3}, top_view_files);                          % Extract columns (numbers)
rows2 = cellfun(@(x) x{2}, side_view_files, 'UniformOutput', false);  % Extract rows (letters)
cols2 = cellfun(@(x) x{3}, side_view_files);                          % Extract columns (numbers)

% Convert group to numeric for sorting
[~, sortIdx1] = sortrows([double(cell2mat(rows1))', cols1'], [1, 2]);
sorted_top_view_files = top_view_files(sortIdx1);
[~, sortIdx2] = sortrows([double(cell2mat(rows2))', cols2'], [1, 2]);
sorted_side_view_files = side_view_files(sortIdx2);

% Calculate velocity for each fish and find global min and max
global_min = Inf;
global_max = -Inf;
velocity_all = {}; % Store velocity data for each fish

for i = 1:length(sorted_side_view_files)
    fileInfo1 = sorted_top_view_files{i};
    fileName1 = fileInfo1{1};
    fileInfo2 = sorted_side_view_files{i};
    fileName2 = fileInfo2{1};
   
    fish_side = readmatrix(fullfile(folderPath, fileName2));
    fish_top = readmatrix(fullfile(folderPath, fileName1));

    % Validate data points based on score threshold
    Score = all([fish_top(:, [7, 10]) fish_side(:, [4, 7])] > 0.5, 2);
    consecutive_invalid = 0;
    valid_data = true;

    for j = 2:length(Score)
        if ~Score(j)
            consecutive_invalid = consecutive_invalid + 1;
            fish_top(j, :) = fish_top(j - 1, :);
            fish_side(j, :) = fish_side(j - 1, :);
        else
            consecutive_invalid = 0;
        end
        if consecutive_invalid > 150
            valid_data = false;
            break;
        end
    end

    if valid_data
        x = (fish_top(:, 5) + fish_top(:, 8)) / 2;
        y = (fish_top(:, 6) + fish_top(:, 9)) / 2;
        z = (fish_side(:, 3) + fish_side(:, 6)) / 2;
        if length(z) > 1
            velocity = sqrt(sum(diff([x, y, z]).^2, 2)) * FPS * mm_per_pixel; % Compute velocity
            velocity_all{i} = velocity;
            global_min = min(global_min, min(velocity));
            global_max = max(global_max, max(velocity));
        else
            velocity_all{i} = NaN;
        end
    end
end

% Visualization of velocity for each fish
figure;
numFish = length(sorted_side_view_files);
for i = 1:numFish
    subplot(8, 6, i);
    velocity = velocity_all{i};
    if ~isnan(velocity)
        time = (1:length(velocity)) / FPS;
        plot(time, velocity);
        hold on;
        ylim([global_min, 50]); % Set unified y-axis range
        fileInfo = sorted_side_view_files{i};
        title(sprintf('Fish %s%d', fileInfo{2}, fileInfo{3}));
        xlabel('Time (s)');
        hold off;
    end
end