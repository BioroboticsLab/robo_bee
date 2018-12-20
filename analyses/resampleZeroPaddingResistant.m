function resampledData = resampleZeroPaddingResistant(data, resampled_size)

% resample does zero padding
% this disturbs the beginning end end of our curves
% we bring the curve closer to x-axis
% such that the influence of the zero padding is not so bad anymore
X1 = data(1);
X2 = data(end);
q = (X1-X2)/2;
% move the data
dataRelocated = data - q;
resampledData = resample(dataRelocated, resampled_size, length(dataRelocated));
% now move the curve back to original place
resampledData = resampledData + q;