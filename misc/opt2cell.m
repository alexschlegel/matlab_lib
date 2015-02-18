function cOpt = opt2cell(opt)
% opt2cell
% 
% Description:	convert an options struct to a varargin-type cell of option
%				name/option value pairs
% 
% Syntax:	cOpt = opt2cell(opt)
% 
% In:
% 	opt	- an options struct returned by ParseArgs
% 
% Out:
% 	cOpt	- opt as a cell
% 
% Updated:	2015-02-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isstruct(opt)
	if isfield(opt,'opt_extra')
		opt_extra	= opt.opt_extra;
		opt			= rmfield(opt,'opt_extra');
		
		cField			= fieldnames(opt);
		cFieldExtra		= fieldnames(opt_extra);
		
		[bDupe,kDupe]	= ismember(cFieldExtra,cField);
		cFieldExtra		= cFieldExtra(~bDupe);
		nFieldExtra		= numel(cFieldExtra);
		
		cField(end+1:end+nFieldExtra)	= cFieldExtra;
		for kF=1:nFieldExtra
			opt.(cFieldExtra{kF})	= opt_extra.(cFieldExtra{kF});
		end
	else
		cField	= fieldnames(opt);
	end
	
	cVal	= struct2cell(opt);
	
	cOpt	= reshape([cField cVal]',[],1);
else
	cOpt	= {};
end
