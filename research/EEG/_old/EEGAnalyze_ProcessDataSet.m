function [dat,stat] = EEGAnalyze_ProcessDataSet(t,dat,sSession,strExperiment,strID,strDirOut,cDerivedData,cFigure,varargin)
% EEGAnalyze_ProcessDataSet
% 
% Description:	calculate derived data and statistics and save figures for a
%				data set
% 
% Syntax:	[dat,stat] = EEGAnalyze_ProcessDataSet(t,dat,sSession,strExperiment,strID,strDirOut,cDerivedData,cFigure,<options>)
% 
% In:
%	t				- the time vector for windows
% 	dat				- the data struct (see EEGAnalyzeSession)
%	sSession		- the session struct
%	strExperiment	- the name of the experiment
%	strID			- the id of the data set
%	strDirOut		- the output directory
%	cDerivedData	- a cell specifying the derived data (see
%					  EEGAnalyze_DerivedData)
%	cFigure			- a cell specifying the figures to save (see
%					  EEGAnalyze_SaveFigures)
%	<options>:
%		ymin:	(<auto>) minimum vertical axis value.  can be a cell of values,
%				one for each ERP type.
%		ymax:	(<auto>) maximum vertical axis value.  can be a cell of values,
%				one for each ERP type.
%		stat:	([]) pass if the stat struct has already been calculated and
%				only the figures should be processed 
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	dat		- the updated data struct
%	stat	- a struct of statistical results
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'ymin'		, []	, ...
		'ymax'		, []	, ...
		'stat'		, []	, ...
		'silent'	, false	  ...
		);

if isempty(opt.stat)
	%calculate the derived data entries
		dat	= EEGAnalyze_DerivedData(dat,sSession,cDerivedData,'silent',opt.silent);
	%calculate statistics
		stat	= EEGAnalyze_CalculateStatistics(dat,'silent',opt.silent);
else
	stat	= opt.stat;
end

%save figures for the windows
	EEGAnalyze_SaveFigures(t,stat,strExperiment,strID,strDirOut,cFigure,'ymin',opt.ymin,'ymax',opt.ymax,'silent',opt.silent);
