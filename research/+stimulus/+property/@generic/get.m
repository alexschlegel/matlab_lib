function [value,varargout] = get(obj)
% stimulus.property.generic.get
% 
% Description:	get the value of the property
% 
% Syntax: [value,obj] = obj.get()
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[value,b]	= GenerateOne();

if ~b
	tStart	= nowms;
	tNow	= tStart;

	while ~b && tNow <= tStart+obj.timeout
		[value,b]	= GenerateOne();
		
		tNow	= nowms;
	end
end

if b
	if nargout>1
		varargout{1}	= obj.set(value);
	end
else
	error('could not generate a valid property value');
end

%-------------------------------------------------------------------------------
function [value,b] = GenerateOne()
	value	= obj.generate;
	b		= obj.test_exclude(value);
end
%-------------------------------------------------------------------------------

end
