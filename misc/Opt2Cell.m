function cOpt = Opt2Cell(opt)
% Opt2Cell
% 
% Description:	convert an options struct to a varargin-type cell of
%				option name/option value pairs
% 
% Syntax:	cOpt = Opt2Cell(opt)
% 
% In:
% 	opt	- an options struct returned by ParseArgs
% 
% Out:
% 	cOpt	- opt as a cell
% 
% Updated:	2010-07-06
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
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
