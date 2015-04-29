function sPath = structtreepath(s,varargin)
% structtreepath
% 
% Description:	construct the paths of a struct tree
% 
% Syntax:	sPath = structtreepath(s,<options>)
% 
% In:
% 	s	- a struct tree
%	<options>:
%		output:	('struct') the type of output. either 'struct' to construct a
%				struct tree with the same structure as the input, but in which
%				each endpoint is a cell of strings specifying the path to that
%				endpoint, or 'cell' to construct an Nx1 cell of those paths
% 
% Out:
% 	sPath	- see <output> above
% 
% Updated: 2015-04-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, 'struct'	  ...
		);

opt.output	= CheckInput(opt.output,'output',{'struct','cell'});

switch opt.output
	case 'struct'
		sPath	= PathAsStruct(s,{});
	case 'cell'
		sPath	= PathAsCell(s,{});
end

%------------------------------------------------------------------------------%
function s = PathAsStruct(s,cPathParent)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	for kF=1:nField
		strField	= cField{kF};
		cPathField	= [cPathParent; strField];
		
		if isstruct(s.(strField))
			s.(strField)	= PathAsStruct(s.(strField),cPathField);
		else
			s.(strField)	= cPathField;
		end
	end
%------------------------------------------------------------------------------%
function cPath = PathAsCell(s,cPathParent)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	cPath	= {};
	for kF=1:nField
		strField	= cField{kF};
		cPathField	= [cPathParent; strField];
		
		if isstruct(s(1).(strField))
			cPath	= [cPath; PathAsCell(s(1).(strField),cPathField)];
		else
			cPath	= [cPath; {cPathField}];
		end
	end
%------------------------------------------------------------------------------%
