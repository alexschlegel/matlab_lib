function obj = subsasgn(obj,s,b)
% subsasgn
% 
% Description:	overloaded subsasgn to make collection members immediately
%				accessible
% 
% Syntax: obj = subsasgn(obj,s,b)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if strcmp(s(1).type,'.')
	strProp	= s(1).subs;
	
	if numel(s)>1
		if isfield(obj.prop,strProp)
			x	= obj.prop.(strProp);
			x	= builtin('subsasgn',x,s(2:end),b);
			
			obj.prop.(strProp)	= x;
		else
			obj	= builtin('subsasgn',obj,s,b);
		end
	else
		add(obj,strProp,'generic',b);
	end
else
	obj	= builtin('subsasgn',obj,s,b);
end
