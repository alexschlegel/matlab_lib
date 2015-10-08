function x = subsref(obj,s)
% subsref
% 
% Description:	overloaded subsref to make collection members immediately
%				accessible
% 
% Syntax: x = subsref(obj,s)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nSubs	= numel(s);

switch s(1).type
	case '.'
		strProp	= s(1).subs;
		
		assert(isfield(obj.prop,strProp),'%s is not a valid property',strProp);
		
		x	= obj.prop.(strProp);
		
		if nSubs==1
			[x,obj.prop.(strProp)]	= x.get;
		else
			x	= subsref(x,s(2:end));
		end
	otherwise
		x	= builtin('subsref',obj,s);
end
