function layers = buildDL_function(numOfFeatures, numOfOutputs)
% 
% Build the neural network for NODDI parameter estimation
% 

% name of the input
inputName = 'Signal';

% number of output
numOfOutput = numOfOutputs;

% name of the output
outputName = 'NODDIparams';

% width of the model
numOfHiddenNodes1 = 150;
numOfHiddenNodes2 = 150;
numOfHiddenNodes3 = 150;


% create the layers
layers = [
    featureInputLayer(numOfFeatures, 'Name', inputName);
    fullyConnectedLayer(numOfHiddenNodes1, 'Name', 'fc1');
    eluLayer('Name', 'relu4fc1');
    fullyConnectedLayer(numOfHiddenNodes2, 'Name', 'fc2');
    reluLayer('Name', 'relu4fc2');
    fullyConnectedLayer(numOfHiddenNodes3, 'Name', 'fc3');
    reluLayer('Name', 'relu4fc3');
    fullyConnectedLayer(numOfOutput, 'Name', 'fcFinal');
    regressionLayer('Name', outputName);
    ];


