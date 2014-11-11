function d = FSLDisplacement(cDirFEAT,varargin)
% FSLDisplacement
% 
% Description:	read the displacement for a functional run that has been
%				preprocessed using FEAT
% 
% Syntax:	d = FSLDisplacement(cDirFEAT,<options>)
% 
% In:
% 	cDirFEAT	- the path to a feat directory, or a cell of paths
%	<options>:
%		type:	('rel') one of the following to specify what type of displacement
%				to return:
%					'rel':	relative displacement
%					'abs':	absolute displacement
%		stat:	('mean') the type of statistic to return:
%					'mean':		mean displacement
%					'median':	median displacement
%					'max':		max displacement
%					n:			the nth percentile of displacements
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	d	- an Nx1 array of the mean displacement, in mm, for the specified runs
% 
% Updated: 2012-04-17
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'type'		, 'rel'		, ...
		'stat'		, 'mean'	, ...
		'silent'	, false		  ...
		);

%parse the type
	opt.type	= CheckInput(opt.type,'type',{'rel','abs'});
	
	strSuffixType	= ['_' opt.type];

%parse the stat
	if ~isnumeric(opt.stat)
		opt.stat	= CheckInput(opt.stat,'stat',{'mean','median','max'});
		
		switch opt.stat
			case 'mean'
				strSuffixStat	= '_mean';
			otherwise
				strSuffixStat	= '';
		end
	else
		prc			= opt.stat;
		opt.stat	= 'percentile';
		
		strSuffixStat	= '';
	end

cDirFEAT	= ForceCell(cDirFEAT);
cPathMD		= cellfun(@(d) PathUnsplit(DirAppend(d,'mc'),['prefiltered_func_data_mcf' strSuffixType strSuffixStat],'rms'),cDirFEAT,'UniformOutput',false);
bExist		= FileExists(cPathMD);

d			= num2cell(NaN(size(cPathMD)));
d(bExist)	= cellfunprogress(@(f) str2num(fget(f)),cPathMD(bExist),'uniformoutput',false,'label','reading mean displacements','silent',opt.silent);

switch opt.stat
	case 'mean'
		d	= cell2mat(d);
	case 'median'
		d	= cellfun(@median,d);
	case 'max'
		d	= cellfun(@max,d);
	case 'percentile'
		d	= cellfun(@(x) prctile(x,prc),d);
end
