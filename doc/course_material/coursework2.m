%% course work # 2

% The aim of this course work is to get familiar with NODDI model,
% understand how to generate an istance of diffusion signal via this model

% How does it works?
% you should read the comments in the script.
% try to answer the questions where it is required and complete the code to
% complete the tasks.

%% 2.0 Cleaning and loading

% First thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

%% 2.1 NODDI model

% The way to create the NODI model via the NODDI MATLAB toolbox is using
% the MakeModel() function. The input to the function is the following
% string: 'WatsonSHStickTortIsoV_B0'. The motvations behind this name are
% outside the scope of this course.

noddi = MakeModel('WatsonSHStickTortIsoV_B0');

% noddi is a variable of type struct. Explore it and try to understand what
% the different fields refer to. Any guess?
% ANSWER:
% 

% Check the content of noddi.GD.fixed. What does it represent in your
% opinion? 
% ANSWER: 

% Which are the fixed parameters?
% ANSWER:

%% 2.2 Synthesize signal via NODDI model

% Let's now try to use the model to generate an instance of diffusion
% weighted signal via the NODDI model.

% First we need to define an acquisition protocol. We will use the same as
% the NODDI example datset. Use the FSL2Protocol() function as we did in
% the previous course work.
acqProtocol = FSL2Protocol('../../NODDI_example_dataset/NODDI_protocol.bval', ...
    '../../NODDI_example_dataset/NODDI_protocol.bvec');

% next we need to assigne a value to each of the parameters

% ficvf is the fraction of tissue signal from intra-neurite space
ficvf = 0.6;
% di is the intra-neurite diffusivity. This parameter is usually fixed to 1.7 um2/ms
di = 1.7*1e-9;
% kappa is a parameter describing the orientation dispersion of the neurites.
kappa = 2; 
% fiso the fraction of signal from free water (or CSF) compartment
fiso = 0.1;
% diso is the free water diffusivity. this value is usually fixed to 3.0 um2/ms
diso = 3.0*1e-9;
% b0 is the signal value without any diffusion weighting.
% the value is the same as the one we estimated in the GCC voxel.
b0 = 2581;
% theta is the fibre direction polar angle in spherical coordinates
theta = pi/2;
% phi is the fibre direction azimuthal angle in spherical coordinates
phi = 0;

% We use the synthMeas() function to synthetize the DW measures

% let's put the parameters in an array
synthVox_param = [ficvf di kappa fiso diso b0 theta phi];
% let's retrieve the fibre direction in cartesian coordinates
synthVox_fibredir = GetFibreOrientation(noddi.name, synthVox_param);
% and let' generate the signal
synthVox_signal = SynthMeas(noddi.name, synthVox_param(1:end-2), acqProtocol, synthVox_fibredir);

% Try to use the compact voxel data viwer as done in the previous course
% work.

fig_synth_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);

VoxelDataViewer();  % complete this
ylim([0 1.2])


% Compare the result with that of the GCC voxel.
load('coursework_outputs\cw1.mat', 'fig_gcc_compact')

% What differences do you see? Can you explain why?

% ANSWER:

%% 2.3 Generate a test set

% in progress ...


%% 2.4 Save the output

%... consider saving the relevant figures and relevant variables alone

% let's now save the variables we created into a mat file
save('coursework_outputs\cw2.mat', 'noddi', 'acqProtocol',...
    'synthVox_param', 'synthVox_signal')

close all





