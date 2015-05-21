
%

function cCapsule = create_20150429_explore_SNR(varargin)
	stem		= 'explore_SNR';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	spec.pseudoVar	= 'nDataPerRun';
	spec.varName	= {'nDataPerRun' 'nTBlock' 'nRepBlock' 'nRun' 'WSum' 'SNR' 'hrf'};
	spec.varValues	= {24*[2 4],[1,3,6,12],NaN,[5 20],[0.1 0.2],[0.1 0.2 0.3 0.4],[0 1]};
	spec.transform	= @(nDataPerRun,nTBlock,nRepBlock,nRun,WSum,SNR,hrf)...
						deal(nDataPerRun,nTBlock,...
							floor(nDataPerRun/nTBlock),nRun,WSum,SNR,hrf);
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	path			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(path,'cCapsule');

end
