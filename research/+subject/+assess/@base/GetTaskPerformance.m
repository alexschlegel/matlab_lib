function sPerformance = GetTaskPerformance(obj,varargin)
% subject.assess.base.GetTaskPerformance
% 
% Description:	get a record of the performance history for the specified task
% 
% Syntax:	sPerformance = obj.GetTaskPerformance([kTask]=1) OR
%			sPerformance = obj.GetTaskPerformance(d,result)
% 
% In:
%	[kTask]	- the task index
%	d		- an array of difficulties, one for each probe
%	result	- a logical array specifying the result of each probe
% 
% Out:
%	sPerformance	- a struct specifying the performance history:
%						d:	an array of difficulties
%						f:	an array of fractional accuracies, one for each
%							element of d
%						n:	an array specifying the number of times each
%							difficulty was probed
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch numel(varargin)
	case {0,1}
		sHistory	= obj.GetTaskHistory(varargin{:});
		dAll		= sHistory.d;
		resultAll	= sHistory.result;
	case 2
		[dAll,resultAll]	= deal(varargin{:});
	otherwise
		error('invalid inputs');
end

sPerformance	= struct;

[sPerformance.d,kTo,kFrom]	= unique(dAll);
nSample						= numel(sPerformance.d);

[sPerformance.f,sPerformance.n]	= deal(NaN(size(sPerformance.d)));
for kF=1:nSample
	sPerformance.n(kF)	= sum(kFrom==kF);
	sPerformance.f(kF)	= mean(resultAll(kFrom==kF));
end
