
% (Based on archived/capsule-creation-scripts/old_20150403_explore_params.m)

function cCapsule = create_20150424_hrf_comparison(varargin)
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('seed',0);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	cCapsule	= cell(0,1);

	spec.pseudoVar	= 'nDataPerRun';
	spec.varName	= {'nDataPerRun' 'nTBlock' 'nRepBlock' 'nRun' 'WSum' 'hrf'};
	spec.varValues	= {24*(1:4),[1,2,3,4,6,8,12],NaN,5:5:20,[0.1 0.2 0.3],[0 1]};
	spec.transform	= @(nDataPerRun,nTBlock,nRepBlock,nRun,WSum,hrf)...
						deal(nDataPerRun,nTBlock,...
							floor(nDataPerRun/nTBlock),nRun,WSum,hrf);
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= [];
	spec.varName	= {'CRecurX' 'WSum' 'hrf'};
	spec.varValues	= {0:0.1:1,0.1:0.05:0.3,[0 1]};
	spec.transform	= [];
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	spec.pseudoVar	= {'NoiseY' '%recur::sum'};
	spec.varName	= {'NoiseY' '%recur::sum' 'CRecurY' 'WSum' 'hrf'};
	spec.varValues	= {0:0.1:1,0:10:100,NaN,NaN,[0 1]};
	spec.transform	= @filterNoiseYParams;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	path			= ['../data_store/' FormatTime(nowms,'yyyymmdd') ...
						'_hrf_comparison.mat'];
	save(path,'cCapsule');

end

function [NoiseY,pct_recur_vs_sum,CRecurY,WSum,hrf] = ...
		filterNoiseYParams(NoiseY,pct_recur_vs_sum,~,~,hrf)
	nonnoise	= 1 - NoiseY;
	recurFrac	= pct_recur_vs_sum/100;
	CRecurY		= recurFrac * nonnoise;
	WSum		= (1-recurFrac) * nonnoise;
end
