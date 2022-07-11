function parWodi = kappa2odi(params, modelname)
% 
% parWodi = kappa2odi(params, modelname)
% 
% takes the matrix of fitted parameters from NODDI toolbox and substitute
% the column of kappa values with ODI values
% 

kappaIdx = GetParameterIndex(modelname, 'kappa');
scaling = GetScalingFactors(modelname);

parWodi = params;
trueKappa = params(:,kappaIdx,:)./scaling(kappaIdx);

parWodi(:, kappaIdx,:) = atan2(1,  trueKappa)*2/pi;