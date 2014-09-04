function x = Get(ifo,c)
% Group.Info.Get
% 
% Description:	get info
% 
% Syntax:	x = ifo.Get(c)
%
% In:
%	c	- a 1xN cell specifying the path to the info
%
% Out:
%	x	- the info stored in the specified path, or [] if the path did not exist
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ifo.parent.IsRoot()
	x	= DoGet(ifo.root.info,c);
else
	x	= ifo.parent.parent.Info.Get([{ifo.parent.type} c]);
end

%------------------------------------------------------------------------------%
function x = DoGet(s,c)
	switch numel(c)
		case 0
		%get the whole struct
			x	= s;
		case 1
		%get the value
			if isfield(s,c{1})
				x	= s.(c{1});
			else
				x	= [];
			end
		otherwise
		%step along the path
			if isfield(s,c{1}) && isstruct(s.(c{1}))
				x	= DoGet(s.(c{1}),c(2:end));
			else
				x	= [];
			end
	end
end
%------------------------------------------------------------------------------%

end
