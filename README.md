# Estimation of brain tissue microstructure with dMRI

## Purpose

This folder contains the material for "Estimation of brain tissue microstructure with dMRI" course of the 2022 UCL Medical Image Computing Summer School (MedICSS).

## Project aim

The aim of this project is to explore different approaches of estimating brain tissue microstructure parameters from diffusion MRI data.

If you want to know more you can have a look at the introductoy slides available [here](doc/projectDescription/MedICSS_microImg_projectPresentation.pptx).

## Prerequisite

The entire course is developed in [MATLAB](https://uk.mathworks.com/products/matlab.html), so make sure to have it installed on you computer.
The course was tested on MATLAB R2022a. The Deep Learning Toolbox and Statistics and Machine Learning Toolbox are available from 2019a version on, so you should have at least that version.

### MATLAB ad-on toolboxes

You will need to have the following ad-on toolboxes installed on your MATLAB:

* **Optimization** toolbox.

* **Deep Learning Toolbox**.

* **Statistics and Machine Learning Toolbox**.

You can check the ad-ond currently installed on your MATLAB as well as donwload the missing ones simply from your MATLAB main window. You can find the process illustrated by the following screenshots: [step1](figs/prereq/addons1.png), [step2](figs/prereq/addons2.png).

<!---
### MATLAB toolboxes

You will also need to Download the following toolboxes:

* The [NODDI MATLAB toolbox](http://mig.cs.ucl.ac.uk/index.php?n=Download.NODDI).

* The [NIfTI Matlab library](https://github.com/NIFTI-Imaging/nifti_matlab).

* The [NifTI Matlab tools](https://uk.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image).

After the download you should keep track of the path to the folder where they are located.

Suggestion: creat a folder
--->

## Download the project folder

The best way to install this GitHub folder is directly from your MATLAB main window using a simple GUI.  You can find the process illustrated by the following set of screenshots: [step1](figs/download/gitdownload1.png), [step2](figs/download/gitdownload2.png), [step3](figs/download/gitdownload3.png). The documentation of this functionality is available [here](https://it.mathworks.com/help/simulink/ug/clone-git-repository.html).

Alternatively you can download a zip version of the repository from the git repository web page or use the following command from terminal:

```
git clone https://github.com/CIG-UCL/MedICSS_2022_microImag.git
```

## Installation

Once you have downloaded the project folder we need to add the folder to your MATLAB path. You can find the process illustrated by the following set of screenshots: [step1](figs/installation/addpath1.png), [step2](figs/installation/addpath2.png).

## Download the example data set

The data set is available for download as a [compressed zip archive](https://www.nitrc.org/frs/download.php/11758/NODDI_example_dataset.zip).

You should unzip the folder and move it to the clone of the current git repository you downloaded on your computer.

If you are on mac or linux the set of commands from terminal should look something like the following:

```
cd ~/Downloads
unzip NODDI_example_dataset.zip
mv NODDI_example_dataset/ <path_to_project_folder>/MedICSS_2022_microImag/
rm NODDI_example_dataset.zip
```

## Get started

You can find the course material in [`doc/course_material`](doc/course_material).

At the end of each day I will add the solution to the task of the day in [`doc/solutions`](doc/solutions).
