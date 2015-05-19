% For old plot-capsule creation scripts, see
%   scratchpad/archived/capsule-creation-scripts/*
%
%

function cCapsule = create_20150515_various_vs_SNR(varargin)
	stem		= 'various_vs_SNR_alextest';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeOptionDefault('nIteration',15);
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	cCapsule{end+1}	= makeCapsule('nRun', [5 8 11 14 17]);
	cCapsule{end+1}	= makeCapsule('nSubject', [5 8 11 14 17]);
	cCapsule{end+1}	= makeCapsule('nTBlock', [1 3 6 10 15]);
	cCapsule{end+1}	= makeCapsule('nRepBlock', [3 4 5 6 7]);

	if ismember('stubsim',pipeline.uopt.fudge)
		return;
	end

	capPath			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(capPath,'cCapsule');
	fprintf('Capsule(s) saved to %s\n',capPath);

	function capsule = makeCapsule(testvarName,testvarValues)
		snr_range		= [0.1,0.25];
		nSNR			= 20;

		spec.pseudoVar	= 'SNR_index';
		spec.varName	= {testvarName 'SNR_index' 'SNR'};
		spec.varValues	= {testvarValues, 1:nSNR, NaN};
		spec.transform	= @transform;

		function [testvar,SNR_index,SNR] = transform(testvar,SNR_index,~)
			testvar_progress	= (find(testvar==testvarValues) - 1)/numel(testvarValues);
			snr_progress		= max(0,(SNR_index-testvar_progress - 1)/(nSNR - 1));
			SNR					= snr_range * splitdiff(snr_progress).';
			assert(isscalar(SNR),'bug');
		end

		function interpolation_vector = splitdiff(frac)
			interpolation_vector	= [1-frac, frac];
		end

		capsule	= pipeline.makePlotCapsule(spec);
	end
end
