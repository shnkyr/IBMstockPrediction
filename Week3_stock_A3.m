%% STOCK DATA ANALYSIS OF IBM
% A3 Group 
% Shankar Sapkota, Amir KC

%% 1. 	Continuous measurements

% Load the dataset from a CSV file
data = readtable('IBM_2006-01-01_to_2018-01-01.csv'); % Replace with your actual file path

% Convert the 'Date' column to datetime
data.Date = datetime(data.Date, 'InputFormat', 'yyyy-MM-dd');


% Check for duplicate rows based on all columns
[~, idx] = unique(data, 'rows', 'stable');
duplicateIdx = setdiff(1:height(data), idx);

% Display information about duplicates
if ~isempty(duplicateIdx)
    fprintf('There are duplicate entries in the dataset.\n');
    % Optional: Display duplicate rows
    duplicates = data(duplicateIdx, :);
    disp(duplicates);
    
    % Procedure to handle duplicates: remove them
    data(duplicateIdx, :) = []; % Remove duplicate rows
    fprintf('Duplicates have been removed from the dataset.\n');
else
    fprintf('There are no duplicate entries in the dataset.\n');
end

%% 2. Synchronous measurements across variables

% Assuming data.Date is already in datetime format
dateDiffs = diff(data.Date);
gaps = find(dateDiffs > 2);

if isempty(gaps)
    fprintf('No synchronization issues: no missing timestamps found.\n');
else
    fprintf('Synchronization issues: found %d gaps in timestamps.\n', length(gaps));
end


%% 3. Checking for missing timestamps

% Check for any missing values in the dataset
missingData = ismissing(data);

% Display information about missing data
if any(missingData, 'all')
    fprintf('There are some missing entries in the dataset of IBM.\n');
    % Find indices where any variable is missing
    missingIdx = any(missingData, 2);
    
    % Optional: Display rows with missing data
    missingEntries = data(missingIdx, :);
    disp(missingEntries);
    
    % Procedure to handle missing data: interpolate or fill
    for i = 1:width(data)
        if any(missingData(:, i))
            % Assuming numerical data, interpolate missing values
            % For non-numerical data, you may need a different approach
            validIdx = ~missingData(:, i);
            data{missingIdx, i} = interp1(find(validIdx), data{validIdx, i}, find(missingIdx), 'linear', 'extrap');
        end
    end
    fprintf('SO, the Missing values have been interpolated Now.\n');
else
    fprintf('All variables are synchronous across the dataset. :) \n');
end

%% 4. Outlier Detection and Residual Plot

% Load the dataset
data = readtable('IBM_2006-01-01_to_2018-01-01.csv');

% Convert the 'Date' column to datetime
data.Date = datetime(data.Date, 'InputFormat', 'yyyy-MM-dd');

% Set the window size for the moving average
windowSize = 20;  % Adjust this value as needed

% Calculate moving averages for OHLC
data.OpenMA = movmean(data.Open, windowSize);
data.HighMA = movmean(data.High, windowSize);
data.LowMA = movmean(data.Low, windowSize);
data.CloseMA = movmean(data.Close, windowSize);

% Calculate residuals for OHLC
data.OpenResiduals = data.Open - data.OpenMA;
data.HighResiduals = data.High - data.HighMA;
data.LowResiduals = data.Low - data.LowMA;
data.CloseResiduals = data.Close - data.CloseMA;

% Plot the residuals
figure;

subplot(4,1,1);
plot(data.Date, data.OpenResiduals);
title('Open Price Residuals');
ylabel('Residual');
xlabel('Date');

subplot(4,1,2);
plot(data.Date, data.HighResiduals);
title('High Price Residuals');
ylabel('Residual');
xlabel('Date');

subplot(4,1,3);
plot(data.Date, data.LowResiduals);
title('Low Price Residuals');
ylabel('Residual');
xlabel('Date');

subplot(4,1,4);
plot(data.Date, data.CloseResiduals);
title('Close Price Residuals');
ylabel('Residual');
xlabel('Date');

% Enhance plot appearance
sgtitle('Residual Plots for OHLC Prices');
set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure window

%% OUtlier Detection now
% Assuming data is already loaded and contains OHLC columns
% Calculate the moving average for each OHLC price
windowSize = 20;  % Adjust this value as needed
data.OpenMA = movmean(data.Open, windowSize);
data.HighMA = movmean(data.High, windowSize);
data.LowMA = movmean(data.Low, windowSize);
data.CloseMA = movmean(data.Close, windowSize);

% Calculate residuals for OHLC
data.OpenResiduals = data.Open - data.OpenMA;
data.HighResiduals = data.High - data.HighMA;
data.LowResiduals = data.Low - data.LowMA;
data.CloseResiduals = data.Close - data.CloseMA;

% Define Z-score function
zscore = @(v) (v - mean(v)) / std(v);

% Calculate Z-scores for the residuals
data.OpenZScores = zscore(data.OpenResiduals);
data.HighZScores = zscore(data.HighResiduals);
data.LowZScores = zscore(data.LowResiduals);
data.CloseZScores = zscore(data.CloseResiduals);

% Define outlier threshold
threshold = 3;  % Common choice is 3 standard deviations from the mean

% Find outliers based on Z-scores
data.OpenOutliers = abs(data.OpenZScores) > threshold;
data.HighOutliers = abs(data.HighZScores) > threshold;
data.LowOutliers = abs(data.LowZScores) > threshold;
data.CloseOutliers = abs(data.CloseZScores) > threshold;

% Display number of outliers detected for each OHLC variable
fprintf('Number of Open price outliers: %d\n', sum(data.OpenOutliers));
fprintf('Number of High price outliers: %d\n', sum(data.HighOutliers));
fprintf('Number of Low price outliers: %d\n', sum(data.LowOutliers));
fprintf('Number of Close price outliers: %d\n', sum(data.CloseOutliers));
