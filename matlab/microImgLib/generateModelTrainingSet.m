function [trainParams, trainSignal] = generateModelTrainingSet(n, model, protocol, varargin)
% 
% Generates n synthetic voxels using the specified model and the specified
% acquisition protocol.
% 
% generateModelTrainingSet(n, model, protocol)
% generateModelTrainingSet(n, model, protocol, seed)
% 
% you can specify a random seed as seed. It must be an integer.
%
% author: Michele Guerreri

% check if the random number has been input
if ~isempty(varargin)
    rndSeed = varargin{1};
else
    rndSeed = [];
end

% get the parameters
if isempty(rndSeed)
    trainParams = genSynthLabels(n, model.name, ...
        {'ficvf','unif'}, {'di','delta'}, {'odi','unif'}, {'fiso','bim5'}, ...
        {'theta','unif'}, {'phi','unif'});
else
    trainParams = genSynthLabels(n, model.name, {'rng', rndSeed}, ...
        {'ficvf','unif'}, {'di','delta'}, {'odi','unif'}, {'fiso','bim5'}, ...
        {'theta','unif'}, {'phi','unif'});
end

% Generate the signal using the model and the parameters
trainSignal = genRawSignal(trainParams, model, protocol);