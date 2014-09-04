function stat = EEGAnalyze_CalculateStatistics(dat,varargin)
% EEGAnalyze_CalculateStatistics
% 
% Description:	calculate statistics for a data set
% 
% Syntax:	stat = EEGAnalyze_CalculateStatistics(dat,<options>)
% 
% In:
% 	dat	- the data set
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	stat	- the struct of statistical results
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'silent'	, false	  ...
		);

status('calculating statistics','silent',opt.silent);
	
%get the mean and stderr of each element of the data
	stat	= structtreefun(@CalcMandSE,dat);

%------------------------------------------------------------------------------%
function s = CalcMandSE(x)
%calculate mean and stderr
	s.m		= nanmean(x,1);
	s.se	= nanstderr(x,[],1);
%------------------------------------------------------------------------------%

