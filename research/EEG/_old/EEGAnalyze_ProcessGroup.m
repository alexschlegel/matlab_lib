function [dat,stat]	= EEGAnalyze_ProcessGroup(t,dat,sSession,strDirOut,cFigure,varargin)
% EEGAnalyze_ProcessGroup
% 
% Description:	process group data
% 
% Syntax:	[dat,stat]	= EEGAnalyze_ProcessGroup(t,dat,sSession,strDirOut,cFigure,<options>)
% 
% In:
% 	t			- a time vector for windows
%	dat			- a cell of session data (see EEGAnalyzeSession)
%	sSession	- a session struct for one subject (to retrieve parameters)
%	strDirOut	- the output directory
%	cFigure		- a cell specifying the figures to save (see
%				  EEGAnalyze_SaveFigures)
%	<options>:
%		experiment:	('') the name of the experiment
%		ymin:		(<auto>) minimum vertical axis value.  can be a cell of
%					values, one for each ERP type.
%		ymax:		(<auto>) maximum vertical axis value.  can be a cell of
%					values, one for each ERP type.
%		stat:		([]) pass if the stat struct has already been calculated and
%					only the figures should be processed 
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	dat		- the group data
%	stat	- the group stats
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'experiment'	, ''	, ...
		'ymin'			, []	, ...
		'ymax'			, []	, ...
		'stat'			, []	, ...
		'silent'		, false	  ...
		);

if isempty(opt.stat)
	dat	= StructAppend(dat{:},'dimension',1);
else
	dat	= [];
end

[dat,stat]	= EEGAnalyze_ProcessDataSet(t,dat,sSession,opt.experiment,'group',strDirOut,[],cFigure,'ymin',opt.ymin,'ymax',opt.ymax,'stat',opt.stat,'silent',opt.silent);
