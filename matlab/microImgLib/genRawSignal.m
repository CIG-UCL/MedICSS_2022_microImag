function raw_signal = genRawSignal(labels, model, protocol)
% 
% Generate raw signal for both invivo and uniform data distribution 
% 
% 

% defien modename and scaling factors
modelname = model.name;

% get the number of voxels and measurements
nData = protocol.totalmeas;
nUnifVox = size(labels, 1);

% define the output
raw_signal = zeros(nUnifVox, nData);

% loop over the voxels
for i =1:nUnifVox
    % scale the parameters
    x = scaleModelParams(labels(i,:), model, -1);
    % get fibre direction
    fibredir = GetFibreOrientation(modelname, labels(i,:));
    % generate the signal
    raw_signal(i,:) = ...
        SynthMeas(modelname, x(1:end-1), protocol, fibredir);
end

