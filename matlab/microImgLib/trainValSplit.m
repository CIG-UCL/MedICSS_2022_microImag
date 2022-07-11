function [xTrain, yTrain, xValidation, yValidation] =   trainValSplit(signal, labels, numOfSamples, hPercentage, varargin)
% 
% split the data in training set and valiadtion set
% 
% [xTrain, yTrain, xValidation, yValidation] =   trainValSplit(signal, labels, numOfSamples, hPercentage)
% [xTrain, yTrain, xValidation, yValidation] =   trainValSplit(signal, labels, numOfSamples, hPercentage, seed)
% 
% 
% 

if ~isempty(varargin)
    rng(varargin{1});
end

% We use matlab's built-in cvpartitio
hPartition = cvpartition(numOfSamples, 'Holdout', hPercentage);

% indices of the training and validation set
idxTrain = training(hPartition);
idxValidation = test(hPartition);

% extract the training set
xTrain = signal(idxTrain,:);
yTrain = labels(idxTrain,:);


% extract the validation set
xValidation = signal(idxValidation,:);
yValidation = labels(idxValidation,:);
