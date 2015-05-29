
%

function cCapsule = create_20150505_explore_nSig(varargin)
	stem		= 'explore_nSig';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('CRecurX',0.5);
	pipeline	= pipeline.changeOptionDefault('CRecurY',0.5);
	pipeline	= pipeline.changeOptionDefault('CRecurZ',0.0);
	pipeline	= pipeline.changeOptionDefault('noiseMix',0.0);
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	spec.pseudoVar	= {'nDataPerRun' 'CRecur'};
	spec.varName	= {'nDataPerRun' 'nTBlock' 'nRepBlock' 'CRecur' 'CRecurX' 'CRecurY' 'nRun' 'WSum' 'nSig' 'hrf'};
	spec.varValues	= {24*(1:4),[1 3 8],NaN,[0.0 0.5],NaN,NaN,[5 10],[0.1 0.2],[10 30 60 100],[0]};
	spec.transform	= @(nDataPerRun,nTBlock,nRepBlock,CRecur,CRecurX,CRecurY,nRun,WSum,nSig,hrf)...
						deal(nDataPerRun,nTBlock,...
							floor(nDataPerRun/nTBlock),CRecur,CRecur,CRecur,nRun,WSum,nSig,hrf);
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	if ismember('stubsim',pipeline.uopt.fudge)
		return;
	end

	path			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(path,'cCapsule');

end
