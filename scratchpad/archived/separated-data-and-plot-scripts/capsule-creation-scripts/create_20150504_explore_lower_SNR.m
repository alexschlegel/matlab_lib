
%

function cCapsule = create_20150504_explore_lower_SNR(varargin)
	stem		= 'explore_lower_SNR';
	pipeline	= Pipeline(varargin{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('nSubject',10);
	pipeline	= pipeline.changeOptionDefault('WSum',0.1);
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeSeedDefaultAndConsume(0);
	cCapsule	= cell(0,1);

	spec.pseudoVar	= {'nDataPerRun' 'snrIdx' 'ln(SNR)'};
	spec.varName	= {'hrf' 'nDataPerRun' 'snrIdx' 'nTBlock' ...
						'nRepBlock' 'nRun' 'SNR' 'ln(SNR)'};
	spec.varValues	= {0:1,24*(1:4),1:8,[1 3 8],NaN,NaN,NaN,NaN};
	spec.transform	= @transform;
	cCapsule{end+1}	= pipeline.makePlotCapsule(spec);

	capPath			= ['../data_store/' FormatTime(nowms,'yyyymmdd_HHMM_') ...
						stem '.mat'];
	save(capPath,'cCapsule');
	fprintf('Capsules saved to %s\n',capPath);

end

function [hrf,nDataPerRun,snrIdx,nTBlock,nRepBlock,nRun,SNR,lnSNR] = ...
		transform(hrf,nDataPerRun,snrIdx,nTBlock,~,~,~,~)

	scenario	= nDataPerRun/24;
	nRun		= scenario*5;
	nRepBlock	= floor(nDataPerRun/nTBlock);

	% For now, somewhat arbitrary SNR values until we know what makes sense.
	% First row is for HRF==0, second row is for HRF==1.
	max_snr		= { 0.09 0.07 0.05 0.03; ...
					0.50 0.40 0.30 0.20 };
	max_snr		= max_snr{1+hrf,scenario};
	max_snr		= 2*max_snr;	% Double for now
	if hrf==1 && nTBlock==1
		max_snr	= 2*max_snr;	% Increase further for this special case
	end
	% Vary the SNR values slightly to help avoid error-bar collisions
	max_snr		= max_snr/(nTBlock^0.1);

	all_snr		= max_snr*2.^(-7:0);
	SNR			= all_snr(snrIdx);
	lnSNR		= log(SNR);
end
