%% course work # 3

% The aim of this course work is to learn how to use conventional fit
% approach to estimate NODDI model parameters.
% We will explore a few examples and see how to judge the quality of the fit.

% How does it works?
% you should read the comments in the script.
% try to answer the questions where it is required and complete the code to
% complete the tasks.

%% 3.0 Cleaning and loading

% First thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

% load variables previously created

load('coursework_outputs\cw1.mat', 'gccVox_ts')
load('coursework_outputs\cw2.mat', 'synthVox_param', 'synthVox_signal', 'noddi', 'acqProtocol')

%% 3.1 Similarity metrics

% Let's now see how to compute the similarity between the synthesized and
% experimental signal. This is the metric we will try to maximize (or
% minimize in case of dissimilarity) when trying to estimate the parameters

% A very common choice is the root mean squared error between the two.

% Try to ompute RMSE between the synthetic voxel generated in the previous
% course (synthVox_signal) work and the experimental signal in the GCC voxel
% (gccVox_ts). Save the result in voxRMSE.
% Before, normalize both signals by the mean b0 of the GCC voxel (b0_gcc),
% this will give RMSE values which are independent by the overall signal 
% intensity.

b0_gcc = mean(gccVox_ts(acqProtocol.b0_Indices));

gccVox_ts_norm = gccVox_ts./b0_gcc;
synthVox_signal_norm = synthVox_signal/b0_gcc;

voxRMSE = sqrt( ); % complete this

% What value do ypu get? Does it make any sense?
% ANSWER:


%% 3.2 Conventional parameter estimation

% The RMSE is the quantity we aim to minimize modifying the NODDI model
% parameters, such that the two signals look as close as possible.

% This can be achieved using built-in functions in MATLAB. Specifically we
% use the lsqcurvefit() function.

% We will try to fit the model to the GCC voxel signal.
% We will use a simplified approach in which we assume to know the fibre
% direction.
% Hence, we will try to estimate three parameters: the ficvf, the kappa and
% the fiso.

% We need at least four input to the lsqcurvefit() function:
% 1. a function which generates the synthetic signal using noddi model,
%   specifically using left-rihgt oriented fibres. This is called
%   "synthNoddiSignal_LR"
% 2. we need an initial guess for our parameters. Let's use the one we used
%   to generate the synthetic voxel signal "synthVox_param".
% 3. we need the acqProtocol which represents independent variable here.
% 4. we need the signal we want the model to be fitted on. For simplicity
%   we will use a normalized version of the GCC voxel signal "gccVox_ts_norm".

% this might be too difficult
[X, RESNORM] = lsqcurvefit(); % complete this

% Check the function outputs. What values do you get?
% ANSWER: 
% 
% Do you understand what they are?
% ASWER: 

% How does it compare to the RMSE we found earlier? What does it means?
% Does it make sense to compare the two?

% Let's try to compute the sum of square error (SSE) and RMSE using the
% fitted parameters  by our self

fitGCC_sse = ;
fitGCC_rmse = ;

% What values do you get?
% ANSWER:

% What can you said comparing fitGCC_rmse and voxRMSE?
% ANSWER: 

%% 3.3 Parameter estimation quality assessement

% Check the RMSE

% Check the Model fit plot against the experimental data

% RUN THIS CODE AND STO HERE...THE DL PARTI IS STILL IN PROGRESS 
fitGCC_params = synthVox_param;
fitGCC_params([1 3 4]) = X;
scale = GetScalingFactors(noddi.name);
fitGCC_params_scaled = [ fitGCC_params(1:(length(scale)-1)).*scale(1:(end-1)) fitGCC_params(end-1:end)];
QualityOfFit(gccVox_ts, fitGCC_params_scaled, noddi, acqProtocol)


%% 4.3 What can go wrong?

% try to use a different starting point 
% [1 200 1] % no sense results.
% [1 0.1 0] % local minimum

%% 4.4 NODDI toolbox

% Try the NODDI toolbox fitting approach.

% Check the output cost function value.

% compare theresult with the previous.

%% 4.5 Fit a testset (maybe)

% ...

%% 4.6 Save the output

% let's now save the variables we created into a mat file
save('coursework_outputs\cw3.mat')

close all


