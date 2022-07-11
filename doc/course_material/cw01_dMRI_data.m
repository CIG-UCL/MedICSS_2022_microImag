%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is part of the UCL MedICSS 2022 "Estimation of brain tissue 
% microstructure with dMRI" project. The repository of the project is
% available at: https://github.com/CIG-UCL/MedICSS_2022_microImag
% 
% Author: Michele Guerreri (m.guerreri@ucl.ac.uk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% course work # 1: dMRI data

% The aim of this course work is to get familiar with diffusion MRI (dMRI) data.
% After this course you should have an idea of how dMRI data look like.
% You should also get a sense of how to manipulate and visualize dMRI data.

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

%% 1.0 Cleaning and set up

% Let's see how to run the code. Delete the "%{" and "%}" symbols at lines
% 36 and 48. Then use one of the following three options:
% a. Click on "Run Section" button in the editor panel above.
% b. Right click within the code section and click "Run Section".
% c. Use the keyboard  shortcut (ususally  "Ctrl+Enter" or "Cmd+Enter").
% d. Repeat this approach for all the next sections!

%{

% As a first thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

% Start from the right directory
toCourseWorkDIR()

%} 

%% 1.1 Load Voxel dMRI data

%{

% Diffusion data are usually organized in 4D stacks of 3D volumes. Each
% volume corresponds to a diffusion weighted (DW) acquisition with a
% different experimental setup. In general, the experimental setup is 
% summarized by two quantities: the b-value defines the diffusion weighting
% extent; the b-vector describes the direction along which the diffusion is
% encoded. Hence, for each volume we expect to have one b-value and one
% b-vector.

% We can select any voxel of the object imaged and see all the measurements
% along the Volume index dimension (the 4th) for the selected voxel.

% I selected a voxel for you and saved the measurements into a .mat file
% called "voxel_dwi_data". Load the file and check the variable "csfVox".

voxel_dwi_data_path = fullfile('..', '..', 'Data', 'voxel_dwi_data', 'voxel_dwi_data.mat');
load(, 'csfVox'); % complete this

% Describe the "csfVox" viriable and its dimensions. To what they correspond?
% ANSWER:

% It is always better not to use integers when manipulating data. You can
% have unexpected results. Let's convert the csfVox variable into a double
% variable
csfVox = double(); % complete this

%}

%% 1.2 Data visualization: 3D volume stack

%{

% To keep track of the b-values and b-vecs used to acquire the data the
% values are usually saved into text files. Load the "NODDI_protocol.bval"
% and "NODDI_protocol.bvec" files using the "importdata()" function. 
% Assign the output to a "bval" and "bvec" % variables:

bval_path = fullfile('..', '..', 'NODDI_example_dataset/NODDI_protocol.bval');
bval = importdata(); % complete this
bvec_path = fullfile('..', '..', 'NODDI_example_dataset/NODDI_protocol.bvec');
bvec = importdata(); % complete this

% What is the content of the variables? Can you guess what the values refer
% to?
% ANSWER:

% OPTIONAL: if you have extra time try to plot the b-vectors as dots on the
% unitary sphere.


% The above information in the NODDI toolbox is organized slightly
% differently using a structure variable. Run the following command and
% explore the output variable "acqProtocol":

acqProtocol = FSL2Protocol(bval_path, bvec_path);

% Have a look at all the fields of the structure. Any guess of what they
% refer to? Some of them are intricated so don't warry if you don't
% understand all of them.

%}

%% 1.3 Data visualization: Time Series view

%{

% Now we will explore the value of the voxel measures. This strategy of
% exploring the data is key to appreciate the characteristics of DWI data and can help
% identify issues in data formatting and/or acquisition.

% The plot below is sometimes called time series as in the way the data are
% usualluy organized we are plotting the measurements along the time (4th)
% dimension.

% how many acquisitions?
nAcq = acqProtocol.totalmeas; % complete this

% Complete the code below to have the voxel measures vs the acquisition 
% index (from 1 to 81).
fig_csf = figure('Position', [400 300 1200 600], 'color', [ 1 1 1]);
plot(, , '-o', 'LineWidth', 2) % complete this
ylabel('DW signal')
xlabel('Acquisitions')
title('CSF voxel time series')

% What type of tissue are we examining (hint, check the figure title)? 
% Can you describe the image and explain why it looks like this?
% ANSWER:  

% The signal intensity variation reveals how the measurements have been 
% acquired. There are 9 high peaks (~16,000) corresponding to the b=0 measurements.
% The 72 non b=0 measurements are evenly split up between the b=0 s, i.e., 
% 8 measurements per split. The first three sets have intermediate 
% intensity values (~2,000), corresponding to 24 b=700 measurements. 
% The last six sets have the lowest intensity values (~100), corresponding 
% to 48 b=2000 measurements.

% This example shows that, for most common single- or multi-shell DWI 
% acquisitions, one can easily identify, from the time series, which
% measurements are acquired with which bvalues. This information must be 
% consistent with the ordering encoded in the bval file.

% Let's give it a try. Plot the b-values on top of the image
figure(fig_csf);
hold on
plot(, , '--o', 'LineWidth', 1); % complete this
legend('DW signal', 'b-values (s/mm^2)')

%}

%% 1.4 Data visualization: Time Series view of WM

%{

% Let's now see a different example of voxel. Load from the same
% "voxel_dwi_data.mat" file the "gccVox" variable. Don't forget to make it double!

load(, 'gccVox');  % complete this
gccVox = double();  % complete this

% Crteate exactly the same plot as before but for this voxel
fig_gcc = figure('Position', [400 300 1200 600], 'color', [ 1 1 1]);
plot(, , '-o', 'LineWidth', 2)  % complete this
ylabel('DW signal')
xlabel('Acquisitions')
title('GCC voxel time series')

figure(fig_gcc);
hold on
plot(, '--o', 'LineWidth', 1);  % complete this
legend('DW signal', 'b-values (s/mm^2)')

% What type of tissue are we examining this time? 
% ANSWER:  

% Compared to the ventricle voxel, the b=0 signals are significantly 
% lower (~2500), with lower signal-to-noise ratio (SNR).
% The b=700 and b=2000 measurements vary dramatically for different gradient 
% directions, ranging from ~600 to ~2100. This strong signal dependence on 
% gradient direction is the hallmark of diffusion anisotropy. 
% The highest signal peaks correspond to the gradient directions 
% that are the most perpendicular to the underlying fibres; 
% the lowest signals valleys correspond to the gradient directions that 
% are the most parallel to the underlying fibres.

% We should be able to highlight this gradient dependence by plotting the
% voxel measures vs the dot product between the bvectors and the main fibre direction
% which for the corpus callosum is approximately left-right along the x axis:

fibredir = [1 0 0];

% compute the absolute value of the dot product between fibredirection and
% the b-vectors
dotProduct =  abs();  % complete this

% complete the code to produce the plot of Signal vs dot product
fig_gcc_dot = figure('Position', [400 100 600 600], 'color', [ 1 1 1]);
plot(, , 'x', 'LineWidth', 2);  % complete this
ylabel('DW signal')
xlabel('$\vert \hat{g} \cdot \hat{n} \vert$', 'Interpreter', 'latex')
title('GCC voxel time series')

% What do you see? What does it means?
% ANSWER:

% Try to do the same with the csf voxel. What do you expect?
% ANSWER: 

fig_csf_dot = figure('Position', [400 100 600 600], 'color', [ 1 1 1]);
plot(, , 'x', 'LineWidth', 2);  % complete this
ylabel('DW signal')
xlabel('$\vert \hat{g} \cdot \hat{n} \vert$', 'Interpreter', 'latex')
title('CSF voxel time series')

%}

%% 1.5 Data visualization: compact voxel view

%{

% the last visualization approach we will explore tries to condense  what
% we learned in a compact way.

% let's produce the plot and discuss it:

% We will normalize the data with respect to the mean of the data acquired with
% no diffusion weightings. So we need to compute it.
b0_gcc = mean(gccVox(acqProtocol.b0_Indices));
b0_csf = mean(csfVox(acqProtocol.b0_Indices));

% let's try the compact view for both the CSF and GCC voxels
fig_gcc_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, gccVox, fibredir', b0_gcc, fig_gcc_compact);

fig_csf_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, csfVox, fibredir', b0_csf, fig_csf_compact);

% Can you explain the two output figures?
% What does the dashed black lines correspond to?
% What do the red and blue crosses correspond to?
% Can you explain the different trends?
% ANSWER: 

%}

%% 1.6 Save the output

%{

% Before running this section make sure you have finished your analysis as
% this will close all the open figures

% let's now save the variables we created into a mat file
save( fullfile('coursework_outputs', 'cw1.mat') )

% and close the figures
close all

%}
