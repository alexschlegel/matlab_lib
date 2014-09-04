function cField = FindStruct(s,varargin)
% FindStruct
% 
% Description:	find an element of a struct with a specified value
% 
% Syntax:	cField = FindStruct(s,[<path>],val)
% 
% In:
% 	s			- a struct
%	[<path>)	- optionally specify a struct path common to all immediate,
%				  either as a cell or as separate arguments
%				  fields of s in which to search for the value (see examples)
%	val			- the value to search for
% 
% Out:
% 	cField	- a cell of fields of s that match val
% 
% Example:	If s.a==5, s.b==10, then FindStruct(s,5)=='a';
%			If s.a.d.e==2, s.b.d.e==4, s.c.d.e==5, then
%				FindStruct(s,'d','e',4)==FindStruct(s,{'d','e'},4)==b
% 
% Updated:	2009-03-01
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the arguments
	switch numel(varargin)
		case 0	%oops
			error('You must specify a value to search for.');
		case 1	%no path, just a value to search for
			cPath	= {};
			val		= varargin{1};
		case 2	%one string and value or cell and value
			if iscell(varargin{1})
				cPath	= varargin{1};
			else
				cPath	= {varargin{1}};
			end
			val	= varargin{2};
		otherwise	%separate arguments
			cPath	= varargin(1:end-1);
			val		= varargin{end};
	end

%get the immediate field names
	fn		= fieldnames(s);
	nField	= numel(fn);
%search each field
	bMatch	= false(nField,1);
	for kF=1:nField
		bMatch(kF)	= isequal(GetFieldPath(s,fn{kF},cPath{:}),val);
	end

cField	= fn(bMatch);
