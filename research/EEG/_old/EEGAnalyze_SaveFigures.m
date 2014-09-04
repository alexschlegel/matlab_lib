function EEGAnalyze_SaveFigures(t,stat,strExperiment,strID,strDirOut,cFigure,varargin)
% EEGAnalyze_SaveFigures
% 
% Description:	save a set of figures for a set of analysis results
% 
% Syntax:	EEGAnalyze_SaveFigures(t,stat,cFigure)
% 
% In:
% 	t				- the time vector
%	stat			- the stat struct
%	strExperiment	- the name of the experiment
%	strID			- the ID of the data set
%	strDirOut		- the output directory
%	cFigure			- a cell of cells of key/value pairs of options for
%					  EEGAnalyze_SaveFigure
%	<options>:
%		ymin:	(<auto>) minimum vertical axis value.  can be a cell of values,
%				one for each ERP type.
%		ymax:	(<auto>) maximum vertical axis value.  can be a cell of values,
%				one for each ERP type.
%		silent:	(false) true to suppress status messages
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'ymin'		, []	, ...
		'ymax'		, []	, ...
		'silent'	, false	  ...
		);
[opt.ymin,opt.ymax]			= ForceCell(opt.ymin,opt.ymax);

cERP						= fieldnames(stat.win);
[cERP,opt.ymin,opt.ymax]	= varfun(@(x) reshape(x,[],1),cERP,opt.ymin,opt.ymax);
[cERP,opt.ymin,opt.ymax]	= FillSingletonArrays(cERP,opt.ymin,opt.ymax);

nERP	= numel(cERP);

cBase	= fieldnames(stat.win.(cERP{1}));
nBase	= numel(cBase);

nFigure	= numel(cFigure);

progress(nERP*nBase*nFigure,'label','saving figures','silent',opt.silent);
for kE=1:nERP
	strERP	= cERP{kE};
	
	for kB=1:nBase
		strBase	= cBase{kB};
		
		for kF=1:nFigure
			EEGAnalyze_SaveFigure(t,stat,strExperiment,strID,strERP,strBase,strDirOut,cFigure{kF}{:},'ymin',opt.ymin{kE},'ymax',opt.ymax{kE});
			
			progress;
		end
	end
end
