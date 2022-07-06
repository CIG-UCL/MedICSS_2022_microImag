%% course work # 1

% The aim of this course work is to explore diffusion MRI (dMRI) data.
% After this course you should have a sense of how to access and manipulate
% dMRI data.

% How does it works?
% you should read the comments in the script.
% try to answer the questions where it is required and complete the code to
% complete the tasks.

%% 1.0 Cleaning

% First thing let's clean our workspace, clear the command window and close
% all open figures:

clc
clear
close all

%% 1.1 NODDI example data set

% let's have a look at the NODDI example data set. Let's forgo the output
% subfolder for the moment. How many files are there?
% ANSWER: 8

% do you know what they refer to?

% ANSWER:
% 1.    The diffusion data are divided in two parts. A header "NODDI_DWI.hdr"
%       which contains important information about the image such as the
%       physical extension of the voxels. The array of data containing the
%       the signal intennsity in each of the voxels "NODDI_DWI.img".
%       Often these two information are merged in a single file which is
%       stored in a .nii format.
% 2.    The "brain_mask" refers to a mask which is similar to the DWI images
%       but contains only zeros and ones to identify the relevant voxels.
% 3.    The "NODDI_protoccol.bval" and "NODDI_protocol.bvec" are text file. They
%       details how the diffusion data have been acquired.
% 4.    The "roi_mask" is similar to the brain_mask.

% let's now try to access the diffusion data. We will use the
% load_untouch_nii() function. Type the help on the command window and see
% if you figure how to use it. We want to store the DW data into the
% varable "dwi". The header file will be enough to load the data


dwi = load_untouch_nii('../../NODDI_example_dataset/NODDI_DWI.hdr');


% dwi contains both the header and the intensities information organized as
% a structure type of variable.
% type dwi on the command window and press enter to see what fields are there.
% Exploring the stucture is the best way to understand how the info is
% organized...check what is into each field and try to guess what they refer to.

% let's check the dimension of the image. Use the function size() to do it.
% you should refer to the img filed of the structure.
% Assigne the value to the variable dwi_size:

dwi_size = size(dwi.img);

% what does the 4th dimension correspond to?
% ANSWER: the different DWI acquisitions.
% How many acquisitions are there?
% ANSWER: 81.
% what about the other three?
% ANSWER: x = 128, y = 128, z = 50.

% Hence the DWI daa are organized as many 3D volumes stuck together on the
% 4th dimenstion.

%% 1.2 Data visualization: 3D data

% Let's now try to visualize one slice of the first volume. Let's use the
% slice number 26. Use the function imshow()

zslice = 26;
figure,imshow(dwi.img(:,:,zslice,1), [0 6000]);

% how does it look? anything unexpected?
% ANSWER: The image is shown in the wrong orientation (the anterior-posterior
% ax goes from left to right). In MATLAB the the first dimension is the rows 
% while in physical images the x is usually horizontal.

% the right command to visualize the image is the following:
figure,imshow( flipud(dwi.img(:,:,zslice,1)') , [0 6000]);
% this slice is called AXIAL slice

% Do you understand what is goig on?
% ANSWER: the ' transpose the image. The x axis becomes horizhontal and the
% y axis becomes vertical. However the y coordinates grows from top to
% bottom, hence we need to reverse the axis with the finction flipud().

% can you try to visualize the slices orthogonal to the axial slice?
% use x=y=65.
% The slice which includes the voxels with the same x coordinate is called
% SAGITTAL.
% The slice which includes the voxels with the same Y coordinate is called
% CORONAL.

xslice = 65;
yslice = 65;

figure,imshow( flipud( squeeze(dwi.img(xslice,:,:,1))') , [0 6000]);
figure,imshow( flipud( squeeze(dwi.img(:,yslice,:,1))') , [0 6000]);

% we can also try to plot the three slices together
fig_3Dpanel = figure('Position', [680 550 1200 300], 'color', [ 0 0 0]);

subplot(1,3,1)
imshow( flipud( squeeze(dwi.img(xslice,:,:,1))') , [0 6000]);
title(sprintf('Sagittal slice %d', xslice), 'Color', [1 1 1], 'FontWeight', 'bold');

subplot(1,3,2)
imshow( flipud( squeeze(dwi.img(:,yslice,:,1))') , [0 6000]);
title(sprintf('Coronal slice %d', yslice), 'Color', [1 1 1], 'FontWeight', 'bold');

subplot(1,3,3)
imshow( flipud(dwi.img(:,:,zslice,1)') , [0 6000]);
title(sprintf('Axial slice %d', zslice), 'Color', [1 1 1], 'FontWeight', 'bold');

% finally let's check what is the value of the image in the voxel
% identified by the intersection of the thee planes.
% Let's assigne such valye to the variable "intersectVox_val"

intersectVox_val = dwi.img(xslice,yslice,zslice,1);

% ANSWER: 4028

%% 1.3 Data visualization: 3D volume stack

% Next, we should check how the other 3D volumes stacked in the 4th
% dimension look likw.

% Let's visualize the same axial slice for three different volumes:
% we use volumes 1, 2, and 29.

vol1 = 1;
vol2 = 2;
vol3 = 29;

fig_3Dstack = figure('Position', [680 550 1200 300], 'color', [ 0 0 0]);
subplot(1,3,1)
imshow( flipud(dwi.img(:,:,zslice,vol1)') , [0 6000]);
title( sprintf('Volume %d', vol1), 'Color', [1 1 1], 'FontWeight', 'bold')

subplot(1,3,2)
imshow( flipud(dwi.img(:,:,zslice,vol2)') , [0 6000]);
title( sprintf('Volume %d', vol2), 'Color', [1 1 1], 'FontWeight', 'bold')

subplot(1,3,3)
imshow( flipud(dwi.img(:,:,zslice,vol3)') , [0 6000]);
title( sprintf('Volume %d', vol3), 'Color', [1 1 1], 'FontWeight', 'bold')

% What do you see? Any idea of why this is it?
% ANSWER: the three volumes represent data acquired with different
% diffusion weightings (or b-values). Higher is the b-values lowe is the
% signal intensity.
% Also, the contrast across the brain is different (the voxels with higher
% and lower signal are in different parts of the brain). This because of
% the differnt voxel underlying microstructures.
% Hopefully it will be clearer soon...

% What is the value of the image in the same intersection voxel as before 
% in the three volumes? assigne the value intersectVox_volVal

intersectVox_volVal = squeeze( dwi.img(xslice,yslice,zslice,[ vol1 vol2 vol3]) );

% ANSWER: 
% vol1 = 4028
% vol1 = 1639
% vol1 = 630

%% 1.4 Data visualization: Time Series view

% The slice view it is usefull to get a sense of how the data looks like.
% However, there are other ways to explore the data which are fundamental 
% to understand the provided information.
% Specifically we will explore the data one voxel at the time along the
% stack, the so-called "time series".
% This strategy is key to appreciate the characteristics of DWI data and can help
% identify issues in data formatting and/or acquisition.

% Let's now plot the time series of voxel [56 55 26].

csfVox =  [56 55 26];
% check what type the data is. It should be double
csfVox_ts = squeeze( double (dwi.img(csfVox(1),csfVox(2),csfVox(3),:) ) );

ts_size = dwi_size(4);

fig_csf_ts = figure('Position', [400 300 1200 600], 'color', [ 1 1 1]);
plot(1:ts_size, csfVox_ts, '-o', 'LineWidth', 2)
ylabel('DW signal')
xlabel('Acquisitions')
title('CSF voxel time series')

% What type of tissue are we examining (hint, check the figure title)? 
% Can you describe the image and explain why it look like this?
% ANSWER: This example has chosen a voxel in the ventricle (CSF) as the 
% intersection point ([54, 53, 24]). 
% The signal intensity variation reveals
% how the measurements have been acquired. There are 9 high peaks (~16,000)
% corresponding to the b=0 measurements.
% The 72 non b=0 measurements are evenly split up between the b=0 s, i.e., 
% 8 measurements per split. The first three sets have intermediate 
% intensity values (~2,000), corresponding to 24 b=700 measurements. 
% The last six sets have the lowest intensity values (~100), corresponding 
% to 48 b=2000 measurements.

% This example shows that, for most common single- or multi-shell DWI 
% acquisitions, one can easily identify, from the time series, which
% measurements are acquired with which bvalues. This information must be 
% consistent with the ordering encoded in the bval file.

% Let's load the b-value file and see if this is the case:

bval_file = importdata('../../NODDI_example_dataset/NODDI_protocol.bval');

figure(fig_csf_ts);
hold on
plot(1:ts_size, bval_file, '--o', 'LineWidth', 1);

legend('DW signal', 'b-values (s/mm^2)')

% Let's now see a different example, voxel [61 93 26]


gccVox =  [61 93 26];
% check what type the data is. It should be double
gccVox_ts = squeeze( double( dwi.img(gccVox(1),gccVox(2),gccVox(3),:) ) );

ts_size = dwi_size(4);

fig_gcc_ts = figure('Position', [400 300 1200 600], 'color', [ 1 1 1]);
plot(1:ts_size, gccVox_ts, '-o', 'LineWidth', 2)
ylabel('DW signal')
xlabel('Acquisitions')
title('GCC voxel time series')

figure(fig_csf_ts);
hold on
plot(1:ts_size, bval_file, '--o', 'LineWidth', 1);

% What type of tissue are we examining this time? 
% ANSWER: is a voxel in the genu of the corpus callosum ([60, 92, 25]), a 
% region of WM known to exhibit the highest diffusion anisotropy. 
% Compared % to the ventricle voxel, the b=0 signals are significantly 
% lower (~2500), with lower signal-to-noise ratio (SNR).
% The b=700 and b=2000 measurements vary dramatically for different gradient 
% directions, ranging from ~600 to ~2100. This strong signal dependence on 
% gradient direction is the hallmark of diffusion anisotropy. Higher the 
% signal is, more perpendicular is the corresponding gradient direction to 
% the underlying (axon) fibres.
% Subject to the effect of noise, the highest signal correspond to the 
% gradient direction that is the most perpendicular to the underlying 
% fibres; the lowes by plotting the signal vs the dot product between 
% the gradient directions used to acquire the data and the fibre direction
% which for the corpus callosum is approximately left-right along the x axis:

bvec_file = importdata('../../NODDI_example_dataset/NODDI_protocol.bvec');
xdir = [1 0 0];

dotProduct =  abs(xdir*bvec_file) ;

fig_gcc_dot = figure('Position', [400 100 600 600], 'color', [ 1 1 1]);
plot(dotProduct, gccVox_ts, 'x', 'LineWidth', 2);
ylabel('DW signal')
xlabel('$\vert \hat{g} \cdot \hat{n} \vert$', 'Interpreter', 'latex')
title('GCC voxel time series')

% What do you see? What does it means?
% ANSWER:

%% 1.5 Data visualization: compact voxel view

% the last visualization approach we will explore tries to use both the
% approaches above in a compact way.

% let's produce the plot and discuss it:

% first we need to provide the acqusition protocol info in a compact way:
acqProtocol = FSL2Protocol('../../NODDI_example_dataset/NODDI_protocol.bval', ...
    '../../NODDI_example_dataset/NODDI_protocol.bvec');
% We will see more about this later

b0_gcc = mean(gccVox_ts(acqProtocol.b0_Indices));
b0_csf = mean(gccVox_ts(acqProtocol.b0_Indices));

% let's try the compact view for both the CSF and GCC voxels
fig_gcc_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, gccVox_ts, xdir', b0_gcc, fig_gcc_compact);

fig_csf_compact = figure('Position', [400 100 500 800], 'color', [ 1 1 1]);
VoxelDataViewer(acqProtocol, csfVox_ts, xdir', b0_csf, fig_csf_compact);

% Can you explain the two output figures?
% What does the dashed black lines correspond to?
% What do the red and blue crosses correspond to?
% Can you explain the different trends?

%% 1.6 Save the output

%... consider saving the relevant figures and relevant variables alone

% let's now save the variables we created into a mat file
save('coursework_outputs\cw1.mat', 'gccVox_ts', 'fig_gcc_compact')

close all
%% Extra task

% repeat the last point using the following voxels:

extraVox1 = [52 65 26];
extraVox2 = [52 64 36];
extraVox3 = [85 74 43];

% 
% ...
% missing part

% describes the trends. From what tissue type they are from?