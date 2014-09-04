function str = to(x,varargin)
% serialize.to
% 
% Description:	serialize a MATLAB variable
% 
% Syntax:	str = serialize.to(x,<options>)
% 
% In:
% 	x	- any MATLAB variable
%	<options>:
%		***
% 
% Out:
% 	str	- the serialized form of x. can be unserialized later using
%		  serialize.from.
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isnumeric(x)
	str	= serialize.numeric(x,varargin{:});
else
	switch class(x)
		case 'logical'
			str = serialize.logical(x,varargin{:});
		case 'char'
			str	= serialize.char(x,varargin{:});
		case 'cell'
			str	= serialize.cell(x,varargin{:});
		case 'struct'
			str	= serialize.struct(x,varargin{:});
		case 'function_handle'
			str	= serialize.function_handle(x,varargin{:});
		otherwise
			try
				str	= x.serialize();
			catch me
				error(sprintf('%s objects are not supported.',class(x)));
			end
	end
end
