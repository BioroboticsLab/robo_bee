function [ resampled_data ] = resample_around_mean(data, resampled_size)

mean_value = mean(data);
data_around_zero = data - mean_value;
resampled_data_around_zero = resample(data_around_zero, resampled_size, length(data_around_zero));
resampled_data = resampled_data_around_zero + mean_value;