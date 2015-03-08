function varargout = ForceCell(varargin)
% ForceCell
% 
% Description:	wraps each input argument in a cell if it isn't one already
% 
% Syntax:	[x1,...,xN,b1,...,bN] = ForceCell(x1,...,xN,<options>)
% 
% In:
% 	xK	- anything
%	<options>:
%		level:	(1) the number of levels deep cells should exist.  for instance,
%				level==2 forces the output to be cells of cells, level==3 forces
%				cells of cells of cells, etc.
% 
% Out:
% 	xK	- {xK} if xK is not a cell, xK otherwise
%	bK	- true if xK was wrapped
% 
% Updated:	2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%determine how the function was called
	if nargin>2 && isequal(varargin{end-1},'level') && ((isscalar(varargin{end}) && isnumeric(varargin{end})) || nargin~=4 || nargout~=4)
		x		= varargin(1:end-2);
		vargin	= varargin(end-2:end);
	else
		x		= varargin;
		vargin	= {};
	end
%parse optional arguments
	opt	= ParseArgs(vargin,...
			'level'	, 1	  ...
			);

[x,b]	= cellfun(@WrapCell,reshape(x,[],1),'uni',false);

varargout	= [x; b];


%------------------------------------------------------------------------------%
function [x,b] = WrapCell(x)
	y	= x;
	
	n	= opt.level;
	while iscell(y) && n>0
		n	= n - 1;
		
		if ~isempty(y)
			y	= y{1};
		else
			break;
		end
	end
	
	b	= n>0;
	for k=1:n
		x	= {x};
	end
end
%------------------------------------------------------------------------------%

end
