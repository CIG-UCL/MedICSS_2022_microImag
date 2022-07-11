function parWkappa = odi2kappa(params, modelname)
% 
% parWkappa = odi2kappa(params, modelname)
% 
% takes the matrix of fitted parameters from NODDI toolbox and substitute
% the column of odi values with kappa values
% 

kappaIdx = GetParameterIndex(modelname, 'kappa');
scaling = GetScalingFactors(modelname);

parWkappa = params;

parWkappa(:, kappaIdx,:) = scaling(kappaIdx) ./ ( tan(params(:,kappaIdx,:).*pi/2));
