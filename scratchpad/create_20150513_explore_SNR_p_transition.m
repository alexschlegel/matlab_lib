% For old plot-capsule creation scripts, see
%   scratchpad/archived/capsule-creation-scripts/*
%
%

function cCapsule = create_20150513_explore_SNR_p_transition(varargin)
	stem		= 'explore_SNR_p_transition';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeOptionDefault('nIteration',15);
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	wstrengths		= 0.2:0.1:0.7;
	nSNR			= 20;
	snr_ranges		= [
						%low	high
						0.2		0.45	%for least WStrength
						0.1		0.25	%for greatest WStrength 
					  ];

	spec.pseudoVar	= 'SNR_index';
	spec.varName	= {'CRecur' 'WStrength' 'SNR_index' 'SNR'};
	spec.varValues	= {[0 0.5], wstrengths, 1:nSNR, NaN};
	spec.transform	= @transform;

	function [CRecur,WStrength,SNR_index,SNR] = transform(CRecur,WStrength,SNR_index,~)
		wstrength_progress	= (WStrength - wstrengths(1))/(wstrengths(end) - wstrengths(1));
		snr_progress		= (SNR_index - 1)/(nSNR - 1);
		SNR					= splitdiff(wstrength_progress) * ...
								snr_ranges * ...
								splitdiff(snr_progress).';
		assert(isscalar(SNR),'bug');
	end

	function interpolation = splitdiff(alpha)
		interpolation	= [1-alpha, alpha];
	end

	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	if ismember('stubsim',pipeline.uopt.fudge)
		return;
	end

	capPath			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(capPath,'cCapsule');
	fprintf('Capsule(s) saved to %s\n',capPath);
end
