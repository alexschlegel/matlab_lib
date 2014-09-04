function Set(ifo,c,x,varargin)
% Group.Info.Set
% 
% Description:	set info
% 
% Syntax:	ifo.Set(c,x,[bReplace]=true)
%
% In:
%	c			- a 1xN cell specifying the path to the info
%	x			- the value to store
%	[bReplace]	- true to replace existing info
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ifo.parent.IsRoot()
	ifo.root.info	= DoSet(ifo.root.info,ForceCell(c),x,varargin{:});
else
	ifo.parent.parent.Info.Set([{ifo.parent.type} c],x,varargin{:});
end

%------------------------------------------------------------------------------%
function s = DoSet(s,c,x,varargin)
	switch numel(c)
		case 0
		%set the whole struct
			bReplace	= ParseArgs(varargin,true);
			
			if bReplace || isempty(s) || isequal(s,struct)
				s	= x;
			end
		case 1
		%set the value
			bReplace	= ParseArgs(varargin,true);
			
			if bReplace || ~isfield(s,c{1})
				s.(c{1})	= x;
			end
		otherwise
		%step along the path
			if ~isfield(s,c{1})
				s.(c{1})	= struct;
			end
			
			s.(c{1})	= DoSet(s.(c{1}),c(2:end),x,varargin{:});
	end
end
%------------------------------------------------------------------------------%

end
