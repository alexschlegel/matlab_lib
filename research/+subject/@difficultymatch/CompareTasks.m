function stat = CompareTasks(obj)
% subject.difficultymatch.CompareTasks
% 
% Description:	compare the task performances
% 
% Syntax: stat = obj.CompareTasks()
% 
% In:
% 
% Out:
%	stat	- a struct of stats about the tasks:
%				ct:	the contingency table for a chi-square test
%				chi2stat:	the chi-square statistic
%				df:	the chi-square degrees of freedom
%				p:	the p-value of the chi-square test
%				n:	the number of probes for each task
%				f:	the fraction of correct probes for each task
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kTask	= (1:obj.nTask)';

stat	= struct;

%get the performance histories
	if isempty(obj.history)
		b	= repmat({[]},obj.nTask,1);
	else
		sHist	= restruct(obj.history);
		b		= arrayfun(@(k) sHist.result(sHist.task==k),kTask,'uni',false);
	end
	
	n	= cellfun(@numel,b);

%construct the contingency table
	ct	= cellfun(@sum,b);
	ct	= [ct n-ct];

%perform the chi-square test
	[h,p,stat]	= chi2ind(ct);
	stat.p		= p;

%add some other info
	stat.n	= n;
	stat.f	= cellfun(@mean,b);
