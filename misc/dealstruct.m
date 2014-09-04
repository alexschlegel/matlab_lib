function s = dealstruct(varargin)
% dealstruct
% 
% Description:	create a struct with the specified fields and values
% 
% Syntax:	s = dealstruct(f1,...,fN,val) OR
%			s = dealstruct(f,val)
% 
% In:
%	f	- a cell of field names
% 	fK	- the name of the Kth field
%	val	- either the value to assign to each field, or a cell of N values.  if
%		  each field is being set to a cell value, enclose this in a cell
% 
% Out:
% 	s	- the specified struct
% 
% Example:	s = dealstruct('a','b','c',{1 2 3})
%			
% 
% Updated: 2010-07-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin>1 && iscell(varargin{1})
	cField	= varargin{1};
else
	cField	= varargin(1:nargin-1);
end
nField	= numel(cField);

val		= varargin{end};
nVal	= numel(val);

%get each field's value
	if iscell(val)
		switch nVal
			case 1
				if iscell(val{1})
					val	= repmat(val,[1 nField]);
				else
					val	= repmat({val},[1 nField]);
				end
			case nField
				val	= reshape(val,1,[]);
			otherwise
				val	= repmat({val},[1 nField]);
		end
	else
		val	= repmat({val},[1 nField]);
	end
%make cell inputs work nice with the struct call
	bCell		= cellfun(@iscell,val);
	val(bCell)	= cellfun(@(x) {x},val(bCell),'UniformOutput',false);
%construct the struct arguments
	cStruct	= [reshape(cField,1,[]); val];
%construct the struct
	s	= struct(cStruct{:});
