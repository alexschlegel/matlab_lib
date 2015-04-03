
function cCapsule = explore_params(varargin)
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('seed',0);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	cCapsule	= cell(0,1);

	spec.pseudoVar	= 'aggTBlock';
	spec.varName	= {'aggTBlock' 'nTBlock' 'nRepBlock' 'nRun' 'WSum' 'WFullness'};
	spec.varValues	= {24*(1:4),[1,2,3,4,6,8,12],NaN,5:5:20,[0.1 0.2 0.3],[0.1 0.3]};
	spec.filter		= @(u,aggTBlock,nTBlock,nRepBlock,nRun,WSum,WFullness)...
						deal(aggTBlock,nTBlock,...
							floor(aggTBlock/nTBlock),nRun,WSum,WFullness);
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= [];
	spec.varName	= {'CRecurX' 'WSum' 'WFullness'};
	spec.varValues	= {0:0.1:1,0.1:0.05:0.3,[0.1 0.3]};
	spec.filter		= [];
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= {'NoiseY' '%recur::sum'};
	spec.varName	= {'NoiseY' '%recur::sum' 'CRecurY' 'WSum' 'WFullness'};
	spec.varValues	= {0:0.1:1,0:10:100,NaN,NaN,[0.1 0.3]};
	spec.filter		= @filterNoiseYParams;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	save('20150402_explore_params.mat','cCapsule');

end

function [NoiseY,pct_recur_vs_sum,CRecurY,WSum,WFullness] = ...
		filterNoiseYParams(~,NoiseY,pct_recur_vs_sum,~,~,WFullness)
	nonnoise	= 1 - NoiseY;
	recurFrac	= pct_recur_vs_sum/100;
	CRecurY		= recurFrac * nonnoise;
	WSum		= (1-recurFrac) * nonnoise;
end
