function label = GetParameterLabels(param)
%
% function strings = GetParameterLabels(modelname)
%
% Given an input modelname, this function returns the labels assihned to
% the model parameters
%
% author: Gary Hui Zhang (gary.zhang@ucl.ac.uk)
%         Michele Guerreri
%

if (strcmp(param, 'ficvf'))
    label = 'NDI (ficvf)';
elseif (strcmp(param, 'di'))
    label = 'd_I';
elseif (strcmp(param, 'kappa'))
    label = 'ODI (kappa)';
elseif (strcmp(param, 'fiso'))
    label = 'FWF (fiso)';
elseif (strcmp(param, 'diso'))
    label = 'd_{fwf} (diso)';
elseif (strcmp(param, 'b0'))
    label = 'S0 (b0)';
elseif (strcmp(param, 'theta'))
    label = '\theta';
elseif (strcmp(param, 'phi'))
    label = '\phi';
else
    error(['Parameter strings yet to be defined for this model:', param]);
end

