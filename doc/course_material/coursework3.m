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
load('coursework_outputs\cw2.mat', 'synthVox_signal', 'acqProtocol')

%% 3.1 Similarity metrics

% Let's now see how to compute the similarity between the synthesized and
% experimental signal. This is the metric we will try to maximize (or
% minimize in case of dissimilarity) when trying to estimate the parameters

% A very common choice is the root mean squared error between the two.

% Try to ompute RMSE between the synthetic voxel generated in the previous
% course (synthVox_signal) work and the experimental signal in the GCC voxel
% (gccVox_ts). Save the result in voxRMSE.

voxRMSE = sqrt( mean( (synthVox_signal - gccVox_ts).^2 ) );

% What value do ypu get? Does it make any sense?
% ANSWER: 395.7367. Given the scale of the measures the value is sensibel.

% ... argument this 
meanRMSE = sqrt( mean( (gccVox_ts - mean(gccVox_ts)).^2 ) );

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

x = lsqcurvefit(@pippo,[ 0.6 10 0.1 2000 ],acqProtocol, double(gccVox_ts));

a = pippo(x, acqProtocol);

fig_synth_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, a, synthVox_fibredir, b0, fig_synth_compact);
ylim([0 1.2])

% let's try the compact view for both the CSF and GCC voxels
fig_gcc_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, double(gccVox_ts), xdir', b0_gcc, fig_gcc_compact);