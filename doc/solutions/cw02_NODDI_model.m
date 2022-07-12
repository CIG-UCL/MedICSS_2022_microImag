%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is part of the UCL MedICSS 2022 "Estimation of brain tissue 
% microstructure with dMRI" project. The repository of the project is
% available at: https://github.com/CIG-UCL/MedICSS_2022_microImag
% 
% Author: Michele Guerreri (m.guerreri@ucl.ac.uk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% course work # 2: NODDI model 

% The aim of this course work is to get familiar with NODDI model and
% understand how to generate an istance of diffusion signal via this model

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


%% 2.0 Cleaning and setup



% As a first thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

% Start from the right directory
toCourseWorkDIR()



%% 2.1 NODDI model



% The way to create the NODDI model via the NODDI MATLAB toolbox is using
% the MakeModel() function. The input of the function is the following
% string: 'WatsonSHStickTortIsoV_B0'. The motivations behind this name are
% outside the scope of this course.

noddi = MakeModel('WatsonSHStickTortIsoV_B0');

% "noddi" is a variable of type struct. Explore it and try to understand what
% the different fields refer to. Any guess?

% ANSWER (check this answer after you had a look at the variable):
% 1.    "Name" is the string identifying the model.
% 2.    "numParams" is the total number of parameters characterizing the
%       model.
% 3.    "paramsStr" identifies the parameter names.
% 4.    "tissuetype" refers to the type of tissues we are looking at. NODDI
%       can be used on both invivo and exvivo data.
% 5-8.  Are fields that contain useful information. This are particularly 
%       useful when fitting the model to the data using the toolbox.

% Check the content of noddi.GD.fixed. What does it represent in your
% opinion? 

% ANSWER: In NODDI we can't robustly estimate all the parameters. For a
% robust parameter estimation we need to make some assumptions, hence some
% of the parameters are fixed. 

% Which are the fixed parameters?
% ANSWER: the di parameter and the diso parameters are fixed. Also b0 is
% fixed, but its value is actually estimated from the dMRI data itself.



%% 2.2 Synthesize signal via NODDI model



% Let's now try to use the model to generate an instance of diffusion
% weighted signal via the NODDI model.

% First we need to define an acquisition protocol. We will use the same 
% protocol as the one in course work 1. Define the "acqProtocol" as done 
% previously.

bval_path = fullfile('..', '..', 'NODDI_example_dataset/NODDI_protocol.bval');
bvec_path = fullfile('..', '..', 'NODDI_example_dataset/NODDI_protocol.bvec');
acqProtocol = FSL2Protocol(bval_path, bvec_path); % complete this

% next, we need to assign a value to each of the model parameters.

% ficvf is the fraction of tissue signal from intra-neurite space (aka NDI)
ficvf = 0.6;
% di is the intra-neurite diffusivity. This parameter is usually fixed to 1.7 um2/ms
di = 1.7*1e-9; % mm2/ms
% kappa is a parameter describing the orientation dispersion of the neurites.
% This parameter is connected to the ODI parameter
kappa = 2; 
% fiso the fraction of signal from free water (or CSF) compartment (aka FWF)
fiso = 0.1;
% diso is the free water diffusivity. this value is usually fixed to 3.0 um2/ms
diso = 3.0*1e-9; % mm2/ms
% b0 is the signal value without any diffusion weighting.
% the value is the same as the one we estimated in the GCC voxel before.
b0 = 2581;
% theta is the fibre direction polar angle in spherical coordinates
theta = pi/2;
% phi is the fibre direction azimuthal angle in spherical coordinates
phi = 0;

% We use the synthMeas() function to synthetize the DW measures

% let's put the parameters in an array. I started for you from the first
% two...
synthVox_param = [ficvf di kappa fiso diso b0 theta phi]; % complete this
% let's retrieve the fibre direction in cartesian coordinates
synthVox_fibredir = GetFibreOrientation(noddi.name, synthVox_param); % complete this
% and let' generate the signal
% use the help to see how the function works
synthVox_signal = SynthMeas(noddi.name, synthVox_param(1:end-2), acqProtocol, synthVox_fibredir); % complete this

% Check the output.



%% 2.3 Synthetic signal visualization



% Try to use the compact voxel data viwer as done in the previous course
% work. Compare the result with that of the GCC voxel.

fig_synth_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, synthVox_signal, synthVox_fibredir, b0, fig_synth_compact); % complete this
ylim([0 1.2])

load(fullfile('coursework_outputs', 'cw1.mat'), 'fig_gcc_compact')


% What differences do you see? Can you explain why?
% ANSWER:
% The first thing we note is that compared to the invivo measurements
% the signal predicted by the model follows a curve.
% This is because we do not include noise in the model, while the noise is
% present in experimental data.
% The 13 b0s (black dashed lines) have all the same value, which is 1 after
% normalization. Again, this is linked to the absence of noise.
% The curve shapes identified by the blue and red crosses are less steep
% compared to the in-vivo ones. We can argue that the microstructure
% modelled by our parameters is less anisotropic than that of the GCC
% voxel.

% There is a useful function to visualize both experimental and
% model-generated signals in one step:

% let's load the GCC voxel again
load(fullfile('coursework_outputs', 'cw1.mat'), 'gccVox')

% we need to scale the parameters to make it work
synthVox_param_scaled = scaleModelParams(synthVox_param, noddi);

% create the plot
fig_fitQC = QualityOfFit(gccVox, synthVox_param_scaled, noddi, acqProtocol);
ylim([0 1.2])

% What is going on?
% ANSWER: The synthetic signal is now replaced by solid lines. The rest is
% the same.

% This configuration make comparison between predicted and measured signal
% very easy.



%% 2.4 Save the output



% Before running this section make sure you have finished your analysis as
% this will close all the open figures

% let's now save the variables we created into a mat fi
save(fullfile('coursework_outputs', 'cw2.mat'))

% and close the figures
close all


