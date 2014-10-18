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
	cField	= fieldnames(opt);
	nField	= numel(cField);
	
	cOpt	= cell(1,2*nField);
	for kF=1:nField
		cOpt(2*(kF-1)+(1:2))	= {cField{kF} opt.(cField{kF})};
	end
else
	cOpt	= {};
end
