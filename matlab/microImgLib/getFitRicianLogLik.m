function loglik = getFitRicianLogLik(X, protocol, model, meas)
% 
% Compute the Rician log likelihhod from a set of fitted parameters X, given  
% the experimental measure meas.
% 
% loglik = getFitRicianLogLik(X, protocol, model, meas)
% 
% 
% 

% get the fibre direction
fibredir = GetFibreOrientation(model.name, X);

% scale back the partameters to physical dimensions
X_scaled = scaleModelParams(X, model, -1);

% Get the sythetic signal form the parameters
signal = SynthMeas(model.name, X_scaled, protocol, fibredir);

% Compute the noise standard deviation from the experimenatl measures
sig = EstimateSigma(meas, protocol, model);

% get the log likelihood
loglik = RicianLogLik(meas, signal, sig);