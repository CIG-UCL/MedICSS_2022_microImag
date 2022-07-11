function xscaled = scaleModelParams(x, model, varargin)
% 
% xscaled = scaleModelParams(x, model)
% xscaled = scaleModelParams(x, model, scaling_type)
% 
% x are the parameters
% model is the model
% scaling_type specifies the direction of the scaling:
%               1 from physical dimensions to all value close to 1
%               -2 do the opposite
%
% author: michele guerreri

% get the scaling direction
if isempty(varargin)
    s = 1;
else
    s = varargin{1};
end

% grt scaling factors
scale = GetScalingFactors(model.name);

% assume theta and phi are part of the model
tmpx = x(1:(length(scale)-1));

switch s
    case 1
        xscaled = tmpx(1:(length(scale)-1)).*scale(1:(end-1));
    case -1
        xscaled = tmpx(1:(length(scale)-1))./scale(1:(end-1));
    otherwise
        error('Unknown scaling type')
end

xscaled = [xscaled x(end-1:end)];


