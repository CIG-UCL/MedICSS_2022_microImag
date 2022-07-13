%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is part of the UCL MedICSS 2022 "Estimation of brain tissue 
% microstructure with dMRI" project. The repository of the project is
% available at: https://github.com/CIG-UCL/MedICSS_2022_microImag
% 
% Author: Michele Guerreri (m.guerreri@ucl.ac.uk)
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
%    highlighted). Then run the section code and go to the next section.
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

% So, unlike the previous conventional approach with DL we need a set of
% parameters and connected signal exampling the relation between the two.

% Let's creat this "training" dataset.

% We will create N=10e4 voxels randomly, extracting the value of each 
% parameter separately. We will use specific density dist functions. 

% Once we have the parameter combintations we will generate the signal
% using NODDI model and the acquisition protocol we used so far.

% use the function "generateModelTrainingSet" to do so. Let's also use a
% random seed so that we will  all have the same "random" parameters
% extracted.

N = 10e4;
seed1 = 123;
[modelParam, modelSignal] = generateModelTrainingSet(N, noddi, acqProtocol, seed1); % complete this

% Let's explore the parameter distribution. Use the plotDist() function to see
% the generated parameter distributions

% first let's convert the kappa values into odi values
modelParam_odi = kappa2odi(modelParam, noddi.name); % complete this

% chech the function kappa2odi to know the relation between the odi and
% kappa. If kappa is defined [0 +inf] what is the odi range?
% ANSWER: ODI ranges between [0 1].

fig_paramDist = plotDist(modelParam_odi , noddi.paramsStr, noddi.name); % complete this


% Describe the distributions characterizing each parameter. Do they make
% sense to you?
% ANSWER:
% 1. NDI or ficvf is extracted from a uniform distribution between [0 1].
% 2. di is fixed. 
% 3. ODI is connected to the parameter kappa.  it is extracted from a 
%    uniform distribution between [0 1].
% 4. FWF or fiso is extracted from a bimodal distribution mimicking invivo
%    distribution
% 5. d_FWF or diso is fixed.
% 6. b0 is fixed. We use a value of 1.
% 7. theta is extracted from a cos distribution between [0 and pi/2].
% 8. phi is extracted from a uniform distribution between [0 2pi].

% you can give a try with modelParam variable and check what distribution
% of kappa corresponds to a uniform distribution of odi

plotDist(modelParam , noddi.paramsStr, noddi.name); % complete this

% plot the signal of the first voxel to check that everything is all right. Use b0=1.
fig_train_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
fibredir = GetFibreOrientation(noddi.name, modelParam(1,:)); % complete this
VoxelDataViewer(acqProtocol, modelSignal(1,:)', fibredir, 1, fig_train_compact); % complete this

% let's now add some noise to the data to make them look as if they were
% data acquired experimentally.
% We use the "addNoise2Signal" function.

% We use a signal to noise ratio (SNR) of 30 which is similar to the SNR
% usually found in invivo data.
snr = 30;

% again, we set a random seed
seed2 = 234;
 
modelSignal_noisy = addNoise2Signal(modelSignal, snr, seed2); % complete this

% OPTIONAL: have a look at the addNoise2Signal function. How is noise
% generated? What type of distribution is that? Any clue why?
% ANSWER: the MRI images we usually deal with are obtained as the modulus of
% a real and imaginary part of the acquired signal. 
% Both parts have Gaussian noise, and the resulting image has nonlinear 
% combination of these two noise components.
% The distribution of this particular random variable is known as Rician
% distribution.

% Let's plot the first voxel noisy signal
fig_noisy_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, modelSignal_noisy(1,:)', fibredir, 1, fig_noisy_compact); % complete this

% Compare it with the GCC voxel signal plot. Do they look similar?
load(fullfile('coursework_outputs', 'cw1.mat'), 'fig_gcc_compact');



%% 4.2 DL model

% Once we obtained the training set let's define the DL network, i.e. the
% function that we will use to predict the parameters given the dMRI
% signal.

% We will use the function "buildDL_function()"
% To define the network we need to specify the input size and the output
% size.

% The particular model we are going to build uses sigle voxel diffusion MRI
% data to predict the non-orientation dependent NODDI parameters of that same voxel.
% (we are not going to estimate phi and theta)

% What is the input of the network? What is the input size?
% ANSWER: the input is the dMRI data for each voxel at the time. The size
% is 81,

% What is the output to the network? What is the output size?
% ANSWER: the output is the set of parameters we want to estimate for the
% specific voxel we are analyzing. We focus on 3 parameters: ficvf, kappa
% (actually odi) and fiso, i.e. the non-fixed  orientation-independent 
% parameters of NODDI.

numOfFeatures = acqProtocol.totalmeas; % complete this
numOfOutputs = sum(~noddi.GD.fixed) - 2; % 2 are theta and phi 

% build the network
layers = buildDL_function(numOfFeatures, numOfOutputs); % complete this

% use the following command to visualize the network architecture
analyzeNetwork(layers);

% How many layers are there? What type of layers? How many learnable
% parameters? Are you able to deduce the number of parameters given the
% architecture?
% ANSWER: There are 9 layers in total.
% 1. is the input layer, which takes the dMRI data.
% 2. is the 1st fully connected layer.
% 3. is the activation layer of the 1st fc layer. Matlab treats these
% layers separately.
% 4-7 .are 2 other fc layers with the connected activation function.
% 8. is the output layer
% 9. is the regression layer which computes the similarity metric.
%
% The learnable parameters are 58000.

%% 4.3 Network training

% the next step is to update the function (network) we just defined so that 
% we can learn the mapping between input data and output parameters.

% we use the training set we dfefined to do so. 
% First we need to divide the training set into training and validation sets.
% The validation set is useful to understand if we are overfitting the data.

% We use trainValSplit() function in a hold out modality. We use 20% of the
% data for validation. Again, we fix the random seed.
hPercentage = 0.2;
seed3 = 345;
% the train params are only the three we are willing to estimate
trainParam = modelParam_odi(:, [1 3 4]); % complete this
[xTrain, yTrain, xValidation, yValidation] =   trainValSplit(modelSignal_noisy, trainParam, N, hPercentage, seed3); % complete this

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

% Finally, we run the network training. For time reason let it run for a
% couple of minutes and stop it with the button at the top right corner of
% the training GUI.
rng(456);
net = trainNetwork(xTrain, yTrain, layers, mlpOptions); % complete this

% I completed the training for you.
load('..\..\Data\DL_paramEstimation\trained_network.mat', 'net')

% Have a look at the training progress window. Try to understand what each
% line means. What the iterations are? What the epochs are?

%% 4.4 Training assessment

% It seems the training is doing something interesting, but how can we
% judge the quality of the training?
% ANSWER: We can have a look at the performance on the validation set to start.

% We can input the signal of the validation set into the network and
% compare the predicted parameters with the ground truth ones:
valPrediction = predict(net, xValidation); % complete this

% Let's compute the overall RMSE...
val_rmse = mean( sqrt( mean((valPrediction-yValidation).^2, 1) ), 2 ); % complete this

% What value do you get?
% ANSWER: 0.0848

% how does the validation RMSE looks compared to the one obtained for the
% synthetic voxel in course work 3? Does it make sense two compare the two?
% ANSWER: It doesn't make any sense because the RMSE we were computing
% before was computed on the experimental and synthesized measurements.
%  this RMSE is computed on ground truth partameters and estimated
% parameters.

% Also we can have a look at the plots of ground truth vs predicted value:
fig_netPredictionQC = figure('Position', [400 100 1300 400], 'color', [ 1 1 1]);
subplot(1,3,1), plot_gt_vs_prediction(yValidation(:,1), valPrediction(:,1), 'NDI (ficvf)'); % complete this
subplot(1,3,2), plot_gt_vs_prediction(yValidation(:,2), valPrediction(:,2), 'ODI'); % complete this
subplot(1,3,3), plot_gt_vs_prediction(yValidation(:,3), valPrediction(:,3), 'FWF (fiso)'); % complete this

% How do the plots look?
% ANSWER: The data mostly follow the identy line which suggests the estimation
% is overall good. There is a group of data consistently taking 0.5 for
% any value of NDI and of ODI. This data probably corresponds to voxels in
% which FWF is very high, in which is basically impossible assign a value
% to ODI and NDI (there are no tissues). 
% In this "undetermined" situations the DL model predict the mean of the distribution ~0.5.
% You can verify this easely plotting the odi or ndi predicted values vs the FWF gt

figure,plot_gt_vs_prediction(yValidation(:,3), valPrediction(:,1), 'NDI VS FWF'); % complete this
figure,plot_gt_vs_prediction(yValidation(:,3), valPrediction(:,2), 'ODI VS FWF'); % complete this
figure,plot_gt_vs_prediction(yValidation(:,1), valPrediction(:,2), 'ODI VS NDI'); % complete this



%% Extend to an unseen voxel

% We can now try to extend our analysis to unseen data. We will use the
% GCC voxel again.

% Try ro predict the parameters via the network using the DW GCCsignal as
% input. Be mindful to the signal you input...
gccParPrediction = predict(net, gccVox_norm'); % complete this

% This time we don't have the parameter ground truth. How can we assess the
% quality of the estimation?
% ANSWER: we can use the parameters of the conventional fit as ground trurh
% for example and compute the RMSE. Alternatively we can generate a version
% of the signal from the parameters and use it to compute the
% log-likelihood.

% Let's use the parameters estimated by the network to estimate the signal.
% we use the theta and phi from the conventional fit approach.
noddiNet_gcc_odi = noddiFit_gcc;
noddiNet_gcc_odi([1 3 4]) = gccParPrediction; % complete this
noddiNet_gcc = odi2kappa(noddiNet_gcc_odi, noddi.name); % complete this

% compute the loglikelihood and get the fit quality plot. Compare both
% results with those obtained via the conventional fit approach.
loglik_gccnet = getFitRicianLogLik(noddiNet_gcc, acqProtocol, noddi, gccVox); % complete this
fig_noddiQC_gccnet = QualityOfFit(gccVox, noddiNet_gcc, noddi, acqProtocol); % complete this

load(fullfile('coursework_outputs', 'cw3.mat'), 'fig_noddiQC_gcc');

% ANSWER: 
% loglik_gccnet=-5.0265e+05 vs noddiLoglik_gcc=-4.5843e+05.
% The network loglikelihood is higher in absolute value, which means the fit
% from DL is worse compared to that from conventional fit.
% Nontheless, the quality fit plot shows that the model from the DL derived
% parameters describes well the data.

% We showed that our DL network, trained on synthetic data can explain
% in-vivo data quite well.

%% 4.7 Extend the analysis to in-vivo data

% In the last step of our analysis we are going to deploy our DL model on a
% set of invivo data (which include our GCC voxel).

% We are going to use the data from one single slide.

% Let's load the diffusion data
dwi_path = fullfile('..','..','NODDI_example_dataset','output','NODDI_roi.mat');
load(dwi_path, 'roi', 'idx', 'mask');
% we are going to compare the results with those obtaind using the
% conventional fit approach via the NODDI toolbox
fittedParams_path = fullfile('..','..','NODDI_example_dataset','output','FittedParams.mat');
load(fittedParams_path, 'mlps', 'fobj_ml')

% you need first to normalize the data
roi_norm = roi./mean(roi(:,acqProtocol.b0_Indices),2); % complete this

% Let's use the network to predict the parameters
tic
fittedParams_dl = predict(net, roi_norm); % complete this
dl_fitTime = toc;

% how long did it take? We fitted ~5500 voxels. Try to work out the time
% we would need to do the same using the conventional fit approach based on
% the results of the previous course work.

% We can now have a look at the parameter maps
% we need to rearrange the voxel back in the right spatial order
noddiMaps_fit = zeros(size(mask,1), size(mask,2), numOfOutputs);
noddiMaps_dl = zeros(size(mask,1), size(mask,2), numOfOutputs);
% let's convert the fitted params from kappa values to odi
mlps_odi = kappa2odi(mlps, noddi.name);

parIdx = [1 3 4];
% Loop over all the voxels and the parameters
for ii = 1:size(idx,1)
    for jj = 1:numOfOutputs
        noddiMaps_fit(idx(ii,1),idx(ii,2),jj) = mlps_odi(ii,parIdx(jj));
        noddiMaps_dl(idx(ii,1),idx(ii,2),jj) = fittedParams_dl(ii,jj);
    end
end

% define the difference map
map_diff = noddiMaps_fit-noddiMaps_dl;

% put together all the maps in one figure
fig_outMaps = figure('Position', [400 100 1000   750], 'color', [ 0 0 0]);
for jj = 1:numOfOutputs
    subplot(3,3,jj);
    imshow( flipud(noddiMaps_fit(:,:,jj)'), [0 1], Colormap=gray),colorbar('color',[1 1 1]);
    subplot(3,3,numOfOutputs+jj);
    imshow( flipud(map_diff(:,:,jj)'), [-0.2 0.2], Colormap=turbo),colorbar('color',[1 1 1]);
    subplot(3,3,(2*numOfOutputs+jj));
    imshow( flipud(noddiMaps_dl(:,:,jj)'), [0 1], Colormap=gray),colorbar('color',[1 1 1]);
end

% To correctly compare the two approaches we should compute the
% loglikelihood for each voxel and used that fo comparison...
% Do it if you have time :D !



%% 4.6 Save the output



% Before running this section make sure you have finished your analysis as
% this will close all the open figures

% and close the figures
close all


% let's now save the variables we created into a mat fi
save(fullfile('coursework_outputs', 'cw4.mat'), 'net', 'gccParPrediction', 'loglik_gccnet')
