function sPerformance = GetTaskPerformance(obj,kTask,varargin)
% subject.difficultymatch.GetTaskPerformance
% 
% Description:	get a record of the performance history for the specified task
% 
% Syntax:	sPerformance = obj.GetTaskPerformance(kTask,<options>)
% 
% In:
%	kTask	- the task index
%	<options>:
%		d:	(0:0.1:1) the difficulty values for binning
% 
% Out:
%	sPerformance	- a struct specifying the performance history:
%						d:	an array of difficulty bins
%						f:	an array of fractional accuracies, one for each
%							element of d
%						n:	an array specifying the number of times each
%							difficulty bin was probed
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'd'	, 0:0.1:1	  ...
		);

%get the task history
	sHistory	= obj.GetTaskHistory(kTask);
	dAll		= sHistory.d;
	resultAll	= sHistory.result;
	nAll		= numel(dAll);

%bin the history values
	dBin	= reshape(opt.d,[],1);
	nBin	= numel(dBin);
	
	dAllRep	= repmat(reshape(dAll,1,nAll),[nBin 1]);
	dBinRep	= repmat(dBin,[1 nAll]);
	
	dDiff	= abs(dAllRep - dBinRep);
	minDiff	= repmat(min(dDiff,[],1),[nBin 1]);
	
	bMin	= dDiff==minDiff;
	
	dBinned	= arrayfun(@(k) dBin(find(bMin(:,k),1)),(1:nAll)');

%construct the performance history
	sPerformance	= struct('d',reshape(dBin,[],1));
	
	[sPerformance.f,sPerformance.n]	= deal(NaN(nBin,1));
	for kB=1:nBin
		bInBin	= dBinned==dBin(kB);
		
		sPerformance.n(kB)	= sum(bInBin);
		sPerformance.f(kB)	= mean(resultAll(bInBin));
	end
