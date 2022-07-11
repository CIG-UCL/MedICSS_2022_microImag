function h = plotDist(labels, params, modelname)
% 
% Function to plot data distribution
% 
% 
% 

nParam = numel(params);
idxParam = zeros(1,nParam);
for i=1:nParam
    idxParam(i) = GetParameterIndex(modelname, params{i} );
end

%%

h = figure('color', [1 1 1], 'position', [ 114 491  nParam*380+20  395]);

%%

% plot
for i = 1:nParam
    subplot(1,nParam,i);
    histogram(labels(:, idxParam(i) ))
    xlabel('values')
    ylabel('counts')
    title( GetParameterLabels( params{i} ) ,'FontSize',14)
    %xlim([0 1])
end