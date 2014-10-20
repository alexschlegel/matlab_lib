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
% Updated:	2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isstruct(opt)
	cField	= reshape(fieldnames(opt),1,[]);
	
	[bExtra,kExtra]	= ismember('opt_extra',cField);
	if bExtra
		cField(kExtra)	= [];
	end
	
	nField	= numel(cField);
	
	cVal	= cellfun(@(f) opt.(f),cField,'uni',false);
	
	cOpt	= reshape([cField;cVal],[],1);
	
	if bExtra
		cOpt	= [cOpt; opt2cell(opt.opt_extra)];
	end
else
	cOpt	= {};
end
