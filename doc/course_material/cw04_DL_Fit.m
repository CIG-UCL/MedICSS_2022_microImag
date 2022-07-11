%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is part of the UCL MedICSS 2022 "Estimation of brain tissue 
% microstructure with dMRI" project. The repository of the project is
% available at: https://github.com/micGuerr/MedICSS_2022_microImag
% 
% Author: Michele Guerreri (m.guerreri@ucl.ac.uk.ucl)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% course work # 4: Deep learning fit

% The aim of this course work is to learn how to estimate NODDI model 
% parameters using a deep learning based approach.
% We will explore the training set, see how to define and train a
% multi-layer perceptron (MLP) network and test it on a test set.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How to use this code?
% 1. You should read the comments in the script.
% 2. There are some questions through the script, write your answer into the
%    dedicated space. Don't worry if you don't know the answer, you are
%    here to learn!!
% 3. The code is divided in sections. Every time you start a new section you
%    should uncomment the code and complete the missing parts (which are
%    highlighted). Then run the section code and go to the next sextion.
% 4. Repeat step 3. until the end of the script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 4.0 Cleaning and loading

% First thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

% Start from the right directory
toCourseWorkDIR()

% load useful variables previously created
load(fullfile('coursework_outputs', 'cw1.mat'), 'gccVox')
load(fullfile('coursework_outputs', 'cw2.mat'), 'noddi', 'acqProtocol')
load(fullfile('coursework_outputs', 'cw3.mat'), 'gccVox_norm', 'noddiFit_gcc', 'noddiLoglik_gcc');
%% 4.1 Training set

% Remember, the problem of deep learning based parameter estimation is:
% to learn a function (1) that can predict the parameters of interest (2) 
% from the data observed (3), given a set of observed data and parameters 
% of interest pairs (4) exampling the relation between the two.

% Let's explore the training set composed of NODDI model parameters and the
% signal generated from such parameters via the model.

% We will create N=10e4 voxels randomly extracting the parameters from
% specific probability distributions. From those parameters we will
% generate the siganl using NODDI model and the acquisition protocol we
% used so far.

% use the function "generateModelTrainingSet" to do so. Let's also use a
% random seed so that we will  all have the same "random" parameters
% extracted.

N = 10e4;
seed1 = 123;
[modelParam, modelSignal] = generateModelTrainingSet(N, noddi, acqProtocol, seed1);

% Let's first explore the parameters. Use the plotDist() function to see
% the generated parameter distributions

plotDist( kappa2odi(modelParam, noddi.name), noddi.paramsStr, noddi.name);

% Describe the distributions characterizing each parameter. Do they make
% sense to you?
% ANSWER:
% 1. NDI or ficvf is extracted from a uniform distribution between [0 1].
% 2. di is fixed. 
% 3. ODI is connected to thew parameter kappa.  it is extracted from a 
%    uniform distribution between [0 1].
% 4. FWF or fiso is extracted from a bimodal distribution mimiking invivo
%    distribution
% 5. d_FWF or diso is fixed.
% 6. b0 is fixed. We use a value of 1.
% 7. theta is extracted from a cos distribution between [0 and pi/2].
% 8. phi is extracted from a uniform distribution between [0 2pi].


% plot the signal of the first voxel to check everything is all right. Use
% z axis as fibre direction and b0=1.
fig_train_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
fibredir = GetFibreOrientation(noddi.name, modelParam(1,:));
VoxelDataViewer(acqProtocol, modelSignal(1,:)', fibredir, 1, fig_train_compact);

% let's now add some noise to the data to make them look as if they were
% data acquired experimrntally.
% We use the "addNoise2Signal" function.

% We use a signal to noise ratio (SNR) of 30 which is swimilar to the SNR
% usually found in invivo data.
snr = 30;

% again, we set a random seed
seed2 = 234;
 
modelSignal_noisy = addNoise2Signal(modelSignal, snr, seed2);

% Let's plot the first voxel noisy signal
fig_noisy_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, modelSignal_noisy(1,:)', fibredir, 1, fig_noisy_compact);

% Compare it with the GCC voxel. Do they look similar?

%% 4.2 DL model

% Once we obtained the training set let's define the DL network, i.e. the
% function that we will use to predict the parameters given the dMRI
% signal.

% We will use the function "buildDL_function()"
% To define the network we need to specify the input size and the output
% size.

% What is the input to the network? What is the input size?
% ANSWER: the input is the dMRI data for each voxel at the time. The size
% is 81,

% What is the output to the network? What is the output size?
% ANSWER: the output is the set of parameters we want to estimate for the
% spcific voxel we are analysing. We focuse on 3 parameters: ficvf, kappa
% (actually odi) and fiso, i.e. the free  orientation-independent 
% parameters of NODDI.

numOfFeatures = acqProtocol.totalmeas;
numOfOutputs = sum(~noddi.GD.fixed) - 2; % 2 are theta and phi

layers = buildDL_function(numOfFeatures, numOfOutputs);

% use the following command to visualize the network architecture
analyzeNetwork(layers);

% How many layers are there? What type of layers? How many learnable
% parameters? Are you able to deduce the number of parameters given the
% architecture?
% ANSWER: There are 9 layers in total.
% 1. is the input layer, which takes the dMRI data.
% 2. is the 1st fullyconnected layer.
% 3. is the activation layer of the 1st fc layer. Matlab treats these
% layers separately.
% 4-7 .are 2 other fc layers with and connected activation function.
% 8. is the output layer
% 9. is the regression layer which computes the similarity metric.
% The learnable parameters are 58000.

%% 4.3 Network training

% the next step is to update the function we defined so that we can learn
% the mapping between input data and output parameters.

% we use the training set. First we need to divide the training dset into
% training and validation sets. The validation set is useful to understand
% if we are overfitting the data.

% We use trainValSplit() function in a hold out modality. We use 20% of the
% data for validation. Again, we fix the random seed.
hPercentage = 0.2;
seed3 = 345;
% the train params are only the three we are willing to estimate
modelParam_odi = kappa2odi(modelParam, noddi.name);
trainParam = modelParam_odi(:, [1 3 4]);
[xTrain, yTrain, xValidation, yValidation] =   trainValSplit(modelSignal_noisy, trainParam, N, hPercentage, seed3);

% Dose the output make sense to you?

% Next we need to define the training options:
mlpOptions = trainingOptions('adam', ...
    'MaxEpochs',200, ...
    'MiniBatchSize',2500, ...
    'InitialLearnRate',1e-2, ...
    'ValidationPatience', 10, ...
    'ValidationData', {xValidation, yValidation}, ...
    'Plots','training-progress');

% Do you know what each field refers to?

% Finally, we run the network training. For timw reason let it run for a
% couple of minutes and stop it with the button at the top right corner og
% the training GUI.
rng(456);
net = trainNetwork(xTrain, yTrain, layers, mlpOptions);

% I completed the training for you.
load('..\..\Data\DL_paramEstimation\trained_network.mat', 'net')

% Have a look at the training progress window. Try to understand what each
% line means.

%% 4.4 Training assessement

% It seems the training was doing something interesting, but how can we
% judge the quality of the training?
% ANSWER: We can have a look at the performance on the validation set.

% We can input the signal of the validation set into the network and
% compare the predicted parameters with the ground truth ones:
valPrediction = predict(net, xValidation);

% Let's compute the overall RMSE (what is the right combination??):
val_rmse = sqrt( mean((valPrediction-yValidation).^2, 2) );
figure,histogram(val_rmse);

% Also we can have a look at the plots of GT vs predicted value:

fig_netPredictionQC = figure('Position', [400 100 800 500], 'color', [ 1 1 1]);
subplot(1,3,1), scatter(yValidation(:,1), valPrediction(:,1), 'SizeData', 1), title('NDI (ficvf)'),xlabel('Ground truth'),ylabel('Network prediction');
subplot(1,3,2), scatter(yValidation(:,2), valPrediction(:,2), 'SizeData', 1), title('ODI'),xlabel('Ground truth'),ylabel('Network prediction');
subplot(1,3,3), scatter(yValidation(:,3), valPrediction(:,3), 'SizeData', 1), title('FWF (fiso)'),xlabel('Ground truth'),ylabel('Network prediction');


% how does the validation RMSE looks compared to the one obtained for the
% synthetic voxel in course work 3?
% ANSWER: they look


%% Extend to an unseen voxel

gccParPrediction = predict(net, gccVox_norm');

noddoNet_gcc = noddiFit_gcc;
noddoNet_gcc([1 3 4]) = gccParPrediction;
noddoNet_gcc = odi2kappa(noddoNet_gcc, noddi.name);

loglik_gccnet = getFitRicianLogLik(noddoNet_gcc, acqProtocol, noddi, gccVox);
fig_noddiQC_gccnet = QualityOfFit(gccVox, noddoNet_gcc, noddi, acqProtocol);

load(fullfile('coursework_outputs', 'cw3.mat'), 'fig_noddiQC_gcc');



%% 4.6 Save the output

% Befor running this section make sure you have finished your analysis as
% this will close all the open figures

% let's now save the variables we created into a mat fi
save(fullfile('coursework_outputs', 'cw3.mat'))

% and close the figures
close all