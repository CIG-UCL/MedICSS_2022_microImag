function [synthLabs, outname] = genSynthLabels(N, modelname, varargin)
%
% Generate a set of labels specifying the type of dist. over the space of
% parameters.
%
% Usage:
% unifLab = genSynthLabels(N, unifLabWrkSpc, model, {parName, distType}, ...)
% unifLab = genSynthLabels(... , {'rng', randomSeedValue}, ...)
% 
% Input:
%   N               Total number of measures to synthesize
%   modelname       model to which the parameters refer to
%   outWrkSpcPath   prefix and path used to save the workspace
% 
% Output:
% synthLabs         set of parameters
% outname           the name of the set of labels
%
% Author
%   Michele Guerreri
%

model= MakeModel(modelname);

% the total number of combinations is:
synthLabs = zeros(N, 8);

% add b0s and diso values
di_idx = GetParameterIndex(modelname, 'di');
di = model.GD.fixedvals(di_idx)*1e9;
diso_idx = GetParameterIndex(modelname, 'diso');
synthLabs(:, diso_idx) = ones(N,1).*3;
b0_idx = GetParameterIndex(modelname, 'b0');
synthLabs(:, b0_idx) = ones(N,1);

% set the outname
tmp_outname = [];

for i = 1:nargin-2
    
    % Get parameter index
    par_name = varargin{i}{1};
    if strcmp(par_name, 'odi')
        par_name = 'kappa';
    end
    
    if ~strcmp(par_name, 'rng')
        par_idx = GetParameterIndex(modelname, par_name);
    end
    switch varargin{i}{1}
        % fix the random seed
        case 'rng'
            rng(varargin{i}{2});

        % NDI parameter
        case 'ficvf'
            if strcmp(varargin{i}{2}, 'unif')
                synthLabs(:, par_idx) = rand(N,1);
            elseif strcmp(varargin{i}{2}, 'delta')
                synthLabs(:, par_idx) = ones(N,1).*0.7;
            elseif strcmp(varargin{i}{2}, 'norm')
                std = 0.2;
                mu = 0.5;
                % this is actually a GAUSSIAN bounded to be between 0 and 1
                tmp_Ndist = abs(randn(N,1)*std + (1 - mu));
                synthLabs(:, par_idx) = abs(-tmp_Ndist + 1);
            else
                error('%s parameter distribution %s not implemented',...
                    varargin{i}{1}, varargin{i}{2});
            end
            
            % intra-neurite isotropuc diffusivity parameter
        case 'di'
            % additional for-loop to provide a way to break out of the switch statement.
            for j = 1:1
                if strcmp(varargin{i}{2}, 'delta')
                    synthLabs(:, par_idx) = ones(N,1).*di;
                    break
                elseif strcmp(varargin{i}{2}, 'unif')
                    dunif = 1;
                elseif strcmp(varargin{i}{2}, 'norm')
                    dunif = 0;
                elseif strcmp(varargin{i}{2}(1:3), 'mix')
                    dunif = str2double(varargin{i}{2}(4:end))/100;
                else
                    error('%s parameter distribution %s not implemented',...
                        varargin{i}{1}, varargin{i}{2});
                end
                
                % Get the norm/unif/mix distribution
                n_dunif = floor(N*dunif);
                n_dnorm = N - n_dunif;
                dunifIdx = randperm(N, n_dunif);
                dnormIdx = 1:N;
                dnormIdx(dunifIdx) = [];
                synthLabs(dnormIdx, par_idx) = randn(n_dnorm,1)*0.059 + 0.760;
                synthLabs(dunifIdx, par_idx) = rand(n_dunif,1);
            end
            
            % ODI
        case 'odi'
            if strcmp(varargin{i}{2}, 'unif')
                % we sample ODI between 0.002 and 1, to avoid values of kappa too high.
                % if kappa >~ 365 signal from e.n. compartment is nan.
                synthLabs(:, par_idx) = rand(N,1)*0.998+0.002;
            elseif strcmp(varargin{i}{2}, 'delta')
                synthLabs(:, par_idx) = ones(N,1).*0.3;
            elseif strcmp(varargin{i}{2}, 'norm')
                std = 0.15;
                mu = 0.3;
                % this is actually a GAUSSIAN bounded to be between 0 and 1
                tmp_Ndist = abs(randn(N,1)*std + (1 - mu));
                synthLabs(:, par_idx) = abs(-tmp_Ndist + 1);
            else
                error('%s parameter distribution %s not implemented',...
                    varargin{i}{1}, varargin{i}{2});
            end
            
            % FWF parameter
        case 'fiso'
            % additional for-loop to provide a way to break out of the switch statement.
            for j = 1:1
                if strcmp(varargin{i}{2}, 'delta')
                    synthLabs(:, par_idx) = zeros(N,1);
                    break
                elseif strcmp(varargin{i}{2}, 'unif')
                    synthLabs(:, par_idx) = rand(N,1);
                    break
                elseif strcmp(varargin{i}{2}(1:3), 'bim')
                    % set the fraction of full csf voxels to implement
                    fcsf = str2double(varargin{i}{2}(4:end))/100;
                else
                    error('%s parameter distribution %s not implemented',...
                        varargin{i}{1}, varargin{i}{2});
                end
                
                n_csf = floor(N*fcsf);
                n_nonCsf = N - n_csf;
                csfIdx = randperm(N, n_csf);
                nonCsfIdx = 1:N;
                nonCsfIdx(csfIdx) = [];
                csf_std = 0.02;
                nonCsf_std = 0.2;
                % extract the numbers
                synthLabs(csfIdx, par_idx) = 1 - abs( randn( n_csf  ,1)*csf_std );
                synthLabs(nonCsfIdx, par_idx) = abs( randn( n_nonCsf  ,1)*nonCsf_std );
            end
            % polar angle theta
        case 'theta'
            if strcmp(varargin{i}{2}, 'unif')
                synthLabs(:, par_idx) = acos (rand(N,1) );
            elseif strcmp(varargin{i}{2}, 'delta')
                synthLabs(:, par_idx) = zeros(N,1);
            else
                error('%s parameter distribution %s not implemented',...
                    varargin{i}{1}, varargin{i}{2});
            end
            
            % azimuthal angle phi
        case 'phi'
            if strcmp(varargin{i}{2}, 'unif')
                synthLabs(:, par_idx)  = rand(N,1)*2*pi;
            elseif strcmp(varargin{i}{2}, 'delta')
                synthLabs(:, par_idx)  = zeros(N,1);
            else
                error('%s parameter distribution %s not implemented',...
                    varargin{i}{1}, varargin{i}{2});
            end     
    end
    
    % update the output name with the current parameter
    tmp_outname = strcat( tmp_outname,  sprintf('-%s', varargin{i}{:}) );
end

% Need to convert odi in kappa
synthLabs = odi2kappa(synthLabs, modelname);

% set the outname
outname = tmp_outname;