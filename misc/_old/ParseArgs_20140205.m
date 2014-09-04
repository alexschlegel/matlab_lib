function varargout = ParseArgs(vArg,varargin)
% ParseArgs
% 
% Description:	parse a varargin cell of optional arguments
% 
% Syntax:	[v1,v2,...,vN,vRest] = ParseArgs(vArg,d1,d2,...,dN)
%
% In:
%	vArg	- the varargin cell
%	dK		- the default value of the Kth varargin element
% 
% Out:
%	vK		- the value of the Kth varargin element
%	vRest	- the rest of the arguments as a cell
%
% Note: if d1 through dN are specified and vArg has N+1 elements, the last of
%		which is a cell, then vRest is set to the last argument without placing
%		it inside another cell
%
% Updated:	2008-12-21
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nOpt	= numel(varargin);
nOut	= nargout;
nIn		= numel(vArg);

varargout	= cell(1,nOut);

if nOpt==nOut-1	%we want the rest in a cell
	nOut	= nOut - 1;
	
	vRest	= vArg(nOut+1:end);
	if numel(vRest)==1 && iscell(vRest{1})
		vRest	= vRest{1};
	end
	
	varargout{end}	= vRest;
end

if nIn < nOpt
	vArg{nOpt}	= [];
end

for k=1:nOut
	if isempty(vArg{k})
		varargout{k}	= varargin{k};
	else
		varargout{k}	= vArg{k};
	end
end
