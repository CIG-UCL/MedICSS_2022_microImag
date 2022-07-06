function signal = synthNoddiSignal_LR(x, acqProtocol)
% 
% This function geberates synthetic signal using NODDI model. The function
% assumes the main fibre direction oriented left-right along the x-axis.
%
% x is a 3x1 array.
% 
% x(1) is NODDI's ficvf parameter
% x(2) is kappa
% x(3) is fiso
%
% acqProtovol is the acquisition protocol in NODDI toolbox format.
%
% the synthesized signal is stored in signal
% 

% generate the BODDI model
noddi = MakeModel('WatsonSHStickTortIsoV_B0');


% Get the fixed parameter values
params = noddi.GD.fixedvals;

% set the fibre direction left-right
params(GetParameterIndex(noddi.name, 'theta')) = pi/2;
% phi is the fibre direction azimuthal angle in spherical coordinates
params(GetParameterIndex(noddi.name, 'phi'))  = 0;

% set the signal to be normalized
params(GetParameterIndex(noddi.name, 'b0')) = 1;

% set the values of the input parameters
params(GetParameterIndex(noddi.name, 'ficvf')) = x(1);
params(GetParameterIndex(noddi.name, 'kappa')) = x(2);
params(GetParameterIndex(noddi.name, 'fiso')) = x(3);


% let's retrieve the fibre direction in cartesian coordinates
synthVox_fibredir = GetFibreOrientation(noddi.name, params);

% and let' generate the signal
signal = SynthMeas(noddi.name, params(1:end-2), acqProtocol, synthVox_fibredir);
