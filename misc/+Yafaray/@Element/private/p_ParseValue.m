function [cType,cVal] = p_ParseValue(val)
% p_ParseValue
% 
% Description:	parse a value
% 
% Syntax:	[cType,cVal] = p_ParseValue(val)
% 
% Updated: 2012-12-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch class(val)
	case 'double'
		switch numel(val)
			case 1
				cType	= {'fval'};
				cVal	= {n2s(val)};
			case 3
				cType	= {'x','y','z'};
				cVal	= cellfun(@n2s,num2cell(val),'UniformOutput',false);
			case 4
				cType	= {'r','g','b','a'};
				cVal	= cellfun(@n2s,num2cell(val),'UniformOutput',false);
			otherwise
				error('element value is invalid size.');
		end
	case 'int32'
		cType	= {'ival'};
		cVal	= {n2s(val)};
	case 'logical'
		cType	= {'bval'};
		cVal	= {conditional(val,'true','false')};
	case 'char'
		cType	= {'sval'};
		cVal	= {val};
	otherwise
		if isnumeric(val)
			[cType,cVal]	= p_ParseValue(double(val));
		else
			[cType,cVal]	= p_ParseValue(tostring(val));
		end
end

%------------------------------------------------------------------------------%
function s = n2s(n)
	s	= num2str(n,8);
%------------------------------------------------------------------------------%
