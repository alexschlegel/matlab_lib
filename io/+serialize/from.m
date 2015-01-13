function x = from(str)
% serialize.from
% 
% Description:	unserialize a previously serialized object
% 
% Syntax:	x = serialize.from(str)
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= eval(str);

%------------------------------------------------------------------------------%
function n = null()
	n	= [];
end
%------------------------------------------------------------------------------%

end
