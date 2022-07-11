function noisy_signal = addNoise2Signal(raw_signal, snr, varargin)
%
% Add Rician noise to diffusion signal.
%
% Usage:
% noisy_signal = addNoise2Signal(raw_signal, snr)
% noisy_signal = addNoise2Signal(raw_signal, snr, rng)
% 
% Input:
%   raw_signal  Noise free signal.
%   snr         SNR level of the b=0 data.
%   rng         [optional, real number] set the random seed to the
%               specified value
% 
% Output:
% noisy_signal  Noisy signal.

%
% Author
%   Michele Guerreri
%

% if specified, set the random seed
if ~isempty(varargin)
    rng(varargin{1});
end
    
noisy_signal = AddRicianNoise(raw_signal, 1/snr);

        

