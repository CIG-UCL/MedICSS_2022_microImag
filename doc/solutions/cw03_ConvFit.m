%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is part of the UCL MedICSS 2022 "Estimation of brain tissue 
% microstructure with dMRI" project. The repository of the project is
% available at: https://github.com/CIG-UCL/MedICSS_2022_microImag
% 
% Author: Michele Guerreri (m.guerreri@ucl.ac.uk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% course work # 3: Conventional fit

% The aim of this course work is to learn how to use conventional fit
% approach to estimate NODDI model parameters.
% We will explore a few examples and see how to judge the quality of the fit.

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


%% 3.0 Cleaning and loading



% First thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

% Start from the right directory
toCourseWorkDIR()

% load useful variables previously created

load(fullfile('coursework_outputs', 'cw1.mat'), 'gccVox')
load(fullfile('coursework_outputs', 'cw2.mat'), 'synthVox_param', 'synthVox_signal', 'noddi', 'acqProtocol')



%% 3.1 Similarity metrics



% Remember, the problem of conventional parameter estimation is:
% to find the parameters (1) that make the data the model predicts (2) as 
% close (3) as possible (4) to the data we observe.

% Let's now see how to compute the similarity between the predicted and
% observed dMRI signal. This is the metric we will try to maximize (or
% minimize in case of dissimilarity) when trying to estimate the parameters

% A very common choice is the root mean squared error between the two 
% (measuring dissimilarity).

% Try to compute RMSE between the synthetic voxel generated in the previous
% course work 2 (synthVox_signal) and the experimental signal in the GCC voxel
% (gccVox). Save the result in voxRMSE.

% Before, normalize both signals by the mean bval=0 of the GCC voxel (b0_gcc),
% this will give RMSE values which are independent from the overall signal 
% intensity. Use "acqProtocol" to know what are the bval=0.

b0_gcc = mean(gccVox(acqProtocol.b0_Indices)); % complete this

gccVox_norm = gccVox./b0_gcc; % complete this
synthVox_signal_norm = synthVox_signal/b0_gcc; % complete this

voxRMSE = sqrt( mean( (synthVox_signal_norm - gccVox_norm).^2 ) ); % complete this

% What value do you get? Does it make sense?
% ANSWER: 0.1579. Given the scale of the measures the value is sensible.

% a way to check if it makes sense is to check the magnitude of the rmse of
% the measured data with its mean value...the order of magnitude should be
% similar.
meanRMSE = sqrt( mean( (gccVox_norm - mean(gccVox_norm)).^2 ) );



%% 3.2 Conventional parameter estimation



% The RMSE is the quantity we aim to minimize modifying the NODDI model
% parameters, such that the two signals look as close as possible.

% This can be achieved using built-in functions in MATLAB which update the
% parameters systematically. 
% In this example we use the lsqcurvefit() function.

% We will try to fit the model to the GCC voxel signal.
% We will use a simplified approach in which we assume to know the fibre
% direction.
% Hence, we will try to estimate three parameters only:
% the ficvf, the kappa and the fiso.

% We need at least four input to the lsqcurvefit() function:
%
% 1. a function which generates the synthetic signal using noddi model,
%   specifically using left-rihgt oriented fibres. This is called
%   "synthNoddiSignal_LR"
% 2. we need an initial guess for our parameters. Let's use the one we used
%    to generate the synthetic voxel signal "synthVox_param".
% 3. we need the acqProtocol which represents independent variable here.
% 4. we need the signal we want the model to be fitted on. For simplicity
%    we will use the normalized version of the GCC voxel signal "gccVox_norm".

% This could be tricky...try to complete it.
[X, RESNORM] = lsqcurvefit(@synthNoddiSignal_LR, ...
                                [synthVox_param(1) synthVox_param(3) synthVox_param(4)], ...
                                acqProtocol, gccVox_norm);

% Check the function outputs. What values do you get?
% ANSWER: X = [0.6279   23.5554    0.0453]. RESNORM = 0.2097.

% Do you understand what they are?
% ASWER: X contains the parameter values which minimized the cost function
% used in the MATLAB algorithm. RESNORM is the minimum value of the cost
% function found by the algorithm.

% How does it compare to the RMSE we found earlier? What does it means?
% Does it make sense to compare the two?
% ANSWER: The value is higher, which suggests the parameters we found make
% the signal look worse than the one from the synthetic voxel. HOWEVER, you
% should check how the RESNORM is computed!!

% The RESNORM use the sum of squared error (SSE) as similarity metric!

% Let's try to compute the sum of square error (SSE) and RMSE using the
% fitted parameters by our self

fitGCC_sse = sum( (synthNoddiSignal_LR(X, acqProtocol) - gccVox_norm).^2 ); % complete this
fitGCC_rmse = sqrt( mean( (synthNoddiSignal_LR(X, acqProtocol) - gccVox_norm).^2 )); % complete this

% What values do you get?
% ANSWER: fitGCC_sse = 0.2097. fitGCC_rmse = 0.0509;

% What can you said comparing "fitGCC_rmse" and "voxRMSE"?
% ANSWER: "fitGCC_rmse" is lower than "voxRMSE", indicating that the
% parameters obtained from the fitting process give better results than 
% those we used at the starting point.



%% 3.3 Parameter estimation quality assessment



% So, how can we check the quality of the fit? The previous sections showed
% that we need to assess the similarity metrices. Also, we need to be 
% careful to what we are comparing as multiple types of metrics exist.

% However, the problem with this approach is that the similarity values
% are meaningful only if compared with other values.

% Another useful way to assess the quality of the fit is to compare the
% signal synthesized from the fitted parameters and the experimental one,
% similarly to what we did in the previous course work 2.

% The steps to get the plot are the following:
%
% 1. Merge the estimated parameters with the fixed ones from
%    "synthVox_param".
% 2. scale the parameters so that they all have value close to 1. Use
%    "scaleModelParams()".
% 3. Use "QualityOfFit()" function to compare the results.

fitGCC_params = synthVox_param; % complete this
fitGCC_params([1 3 4]) = X; % complete this
fitGCC_params_scaled = scaleModelParams(fitGCC_params, noddi); % complete this
fig_fitQC_gcc = QualityOfFit(gccVox, fitGCC_params_scaled, noddi, acqProtocol); % complete this

% How does it look?
% ANSWER: The synthetic signal follows the experimental data quite well.
% The fit looks better for the blu (high b-vaslues) than for the red 
% (moderate b-values) which underestimates the signal when the dot product
% is close to zero and overestimates the signal when the dot product is
% close to 1.



%% 3.4 What can go wrong?



% The example before gave a good result. But is it the best we can get? And
% how stable the result is?

% We used a specific starting point for the fitting process. Let's see
% what happen if we use two other starting points?

% Repeat the fitting step using these two different starting points.
X0_a = [1 200 1];
X0_b = [0.3 2 0.08];

% complete this
[Xa, RESNORMa] = lsqcurvefit(@synthNoddiSignal_LR, X0_a, ...
                                acqProtocol, gccVox_norm);

% complete this
[Xb, RESNORMb] = lsqcurvefit(@synthNoddiSignal_LR, X0_b, ...
                                acqProtocol, gccVox_norm);

% Use the RESNORM to compare the results with the previous fit.
% What do you see?
% AMNSWER: "RESNORM=0.2097", "RESNORMa=0.1877", "RESNORMb=0.2092".
% Both values are smaller than the previous one, so in principle both of
% them are better.

% Check "Xa" and "Xb", anything strange?
% ANSWER: the ficvf parameter value estimated in Xa is meaningless as it is
% bigger than 1. Being a fraction, ficvf should be in the interval [0 1].
% The values of Xb are all physically acceptable. Hence, using a different
% starting point we got better parameters describing our voxel.

% Hence, 
% 1. The parameter estimation can be very unstable, depending on the
% starting point we use.
% 2. There might be parameter combinations which give better fitting
%    results, but whose values are meaningless for the specific model we 
%    are using values which are.
% 3. The output of the fitting process could be related to a local minimum
%    and not the absolute minimum we are sicking.



%% 3.5 NODDI toolbox



% The NODDI toolbox has a more complex fitting routine which tries to
% minimize any of the above reported potential issues. The function which
% does the job is called "ThreeStageFittingVoxel()".

% Try to use this function to fit the GCC voxel
[~, ~, noddiFit_gcc, noddiLoglik_gcc, ~] = ThreeStageFittingVoxel(gccVox, acqProtocol, noddi); % complete this

% Check the output...
% "noddiFit_gcc" contains all the model parameters (both the fixed and the 
% fitted ones). These values are already scaled!
% "noddiLoglik_gcc" stores the best similarity values obtained with those values.

% Check the "noddiLoglik_gcc", anything unexpected?
% ANSWER: the value is negative. Also it is extremely big in absolute
% terms.
% 
% The reason behind this is that NODDI model uses another similarity metric
% called Likelihood. The likelihood is a measure of similarity,
% hence the bigger the better. The negative sign comes from the fact that 
% we actually use the LOGARITHM of the Likelihood.

% Let's compare the output of this fitting step with the one we run before.

% To compare the result of this fitting routine with the previous ones we
% need to use the same metric. Let's use the scaled "fitGCC_params_scaled"
% parameters to compute the NODDI signal and hence the maximum likelihood:

loglik_gcc = getFitRicianLogLik(fitGCC_params_scaled, acqProtocol, noddi, gccVox);

% Compare the two values of log likelihood. Which of them is better?
% ANSWER: the loglik from the NODDI toolbox is smaller in absolute values,
% but being negative it means that it is bigger, hence the results are
% better compared to our previous naive approach.

% Let's plot the fit quality with these new parameters and compare it with
% previous result:

fig_noddiQC_gcc = QualityOfFit(gccVox, noddiFit_gcc, noddi, acqProtocol); % complete this

% ANSWER: the plot looks slightly better compared to the previous

% OPTIONAL: Have you noticed that the experimental data in the plots 
% look different, but they should be exactly the same? Why is that?
% ANSWER: The NODDI toolbox estimates the fibre direction as well. Hence
% the dot product between gradient directions and fibre direction is
% different, hence the data have different x values and look different, 
% but they aren't.



%% 3.6 How long does it take?



% The voxel fitting takes a few instants to be done. However, we have to
% repeat it for all the voxels in our image. Let's estimate how long can 
% this proces be.

% Use the tic toc function to get an estimate of fitting time per voxel.
% Repeat the GCC fit voxel via the NODDI toolbox routine.

tic
[~, ~, ~, ~, ~] = ThreeStageFittingVoxel(gccVox, acqProtocol, noddi); % complete this
timePerVoxel = toc;

% What result do you get approximately?
% ANSWER: on my laptop is timePerVoxel ~ 0.5 seconds;

% In a 3D DW image the number of voxels is usually of the order of 10e5 
% (e.g. 128*128*60).
% Not all the voxels are used however as many are background. Let's say we
% use 20% of the voxels, hence:

nVox = 10e5*0.2;

% Compute the fitting time in hours and days:

fitTime_h = (timePerVoxel*nVox)/(60*60); % complete this
fitTime_d = fitTime_h/24; % complete this

% ANSWER: The order of magnitude for one subject is of days. It takes about
% one day (~1.2) to get the fit done for one subject. Imagine extending it
% to N subjects.



%% 3.7 Save the output

% Before running this section make sure you have finished your analysis as
% this will close all the open figures

% let's now save the variables we created into a mat fi
save(fullfile('coursework_outputs', 'cw3.mat'))

% and close the figures
close all