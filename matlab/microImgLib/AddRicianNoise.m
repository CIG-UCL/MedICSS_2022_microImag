function S = AddRicianNoise(S_star, sigma, varargin)
% 
% Add Rician noise to MRI signal.
% 
%   S = AddRicianNoise(S_star, sigma)
% 
% Inputs:
%   S_star      array of values containing the noise-free signal. Can be
%               any size and dimension.
%   sigma       Is the standard deviation of the Gaussian distribution from
%               which the rician distribution is constructed.
% Output:
%   S           Array of noisy signal. Has same dimensions as the input
%               signal.
% 

if ~isempty(varargin)
    rng(varargin{1});
end


% Get input size
S_size = size(S_star);

% Create two instances of Gaussian noise
if ~isempty(varargin); rng(varargin{1}); end
n1 = normrnd(0,sigma, S_size);
if ~isempty(varargin); rng(varargin{1}+1); end
n2 = normrnd(0,sigma, S_size);

% Compute magnitude of "real" and "iamginary" noise contribusiotns to the
% signal
S = abs(S_star + n1 + 1i*n2);


