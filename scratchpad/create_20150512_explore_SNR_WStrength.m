% For old plot-capsule creation scripts, see
%   scratchpad/archived/capsule-creation-scripts/*
%
%

function cCapsule = create_20150512_explore_SNR_WStrength(varargin)
	stem		= 'explore_SNR_WStrength';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	spec.varName	= {'SNR' 'WStrength' 'CRecur' 'WFullness'};
	spec.varValues	= {0.05:0.05:0.4, 0.2:0.1:0.7, [0 0.5], [0.15 0.25 0.35]};
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	if ismember('stubsim',pipeline.uopt.fudge)
		return;
	end

	capPath			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(capPath,'cCapsule');
	fprintf('Capsule(s) saved to %s\n',capPath);

end
