
function cCapsule = explore_params(varargin)
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('seed',0);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	cCapsule	= cell(0,1);

	spec.pseudoVar	= 'aggTBlock';
	spec.varName	= {'aggTBlock' 'nTBlock' 'nRepBlock' 'nRun' 'WSum' 'WFullness'};
	spec.varValues	= {[24,48],[1,2,3,4,6,8,12],NaN,5:5:20,[0.1 0.2 0.3],[0.1 0.3]};
	spec.filter		= @(u,aggTBlock,nTBlock,nRepBlock,nRun,WSum,WFullness)...
						deal(aggTBlock,nTBlock,...
							floor(aggTBlock/nTBlock),nRun,WSum,WFullness);
	spec.nIteration	= 10;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= [];
	spec.varName	= {'CRecurX' 'WSum' 'WFullness'};
	spec.varValues	= {0:0.1:1,0.1:0.1:0.3,[0.1 0.3]};
	spec.filter		= [];
	spec.nIteration	= 10;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= {'NoiseY' 'CRecurY%'};
	spec.varName	= {'NoiseY' 'CRecurY%' 'CRecurY' 'WSum' 'WFullness'};
	spec.varValues	= {0:0.1:1,0:10:100,NaN,NaN,[0.1 0.3]};
	spec.filter		= @filterNoiseYParams;
	spec.nIteration	= 10;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	save('20150401_explore_params.mat','cCapsule');

end

function [NoiseY,CRecurY_pct,CRecurY,WSum,WFullness] = ...
		filterNoiseYParams(~,NoiseY,CRecurY_pct,~,~,WFullness)
	nonnoise	= 1 - NoiseY;
	recurFrac	= CRecurY_pct/100;
	CRecurY		= recurFrac * nonnoise;
	WSum		= (1-recurFrac) * nonnoise;
end
