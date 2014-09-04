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
% Updated:	2013-01-23
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%determine how the function was called
	if nargin==nargout
		if nargin~=4
			x		= varargin;
			vOpt	= {};
		elseif isequal(varargin{3},'level') && isscalar(varargin{4})
			x		= varargin(1:2);
			vOpt	= varargin(3:4);
		else
			x		= varargin(1:nargout);
			vOpt	= varargin(nargout+1:end);
		end
	elseif nargout==2*nargin
		x		= varargin;
		vOpt	= {};
	else
		x		= varargin(1:nargout);
		vOpt	= varargin(nargout+1:end);
	end
%parse optional arguments
	%speed this up a bit
% 	opt	= ParseArgsOpt(varargin,...
% 			'level'	, 1	  ...
% 			);
	if numel(vOpt)>1 && ischar(vOpt{1}) && isequal(lower(vOpt{1}),'level') && ~isempty(vOpt{2})
		opt.level	= vOpt{2};
	else
		opt.level	= 1;
	end

n						= numel(x);
varargout(1:n)			= x;
[varargout{n+1:2*n}]	= deal(false);

for k=1:n
	[varargout{k},varargout{n+k}]	= WrapCell(x{k},opt.level);
end

%------------------------------------------------------------------------------%
function [x,b] = WrapCell(x,n)
	e	= x;
	while iscell(e) && n>0
		n	= n - 1;
		if ~isempty(e)
			e	= e{1};
		else
			break;
		end
	end
	
	b	= n>0;
	for k=1:n
		x	= {x};
	end
%------------------------------------------------------------------------------%
