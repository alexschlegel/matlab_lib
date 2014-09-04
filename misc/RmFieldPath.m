function [s,bPathExists] = RmFieldPath(s,varargin)
% RmFieldPath
% 
% Description:	safely remove an element of a multi-level struct
% 
% Syntax:	[s,bPathExists] = GetFieldPath(s,[k]=1,f1,...,fN)
% 
% In:
% 	s	- a struct
%	fK	- the Kth element
% 
% Out:
% 	s			- s with s.f1.....fN removed
%	bPathExists	- true if the path exists, false otherwise
% 
% Updated:	2011-12-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch numel(varargin)
	case 0
		bPathExists	= false;
	case 1
		if isstruct(s) && isfield(s,varargin{1})
			s			= rmfield(s,varargin{1});
			bPathExists	= true;
		else
			bPathExists	= false;
		end
	otherwise
		if isstruct(s) && isfield(s,varargin{1})
			[s.(varargin{1}),bPathExists]	= RmFieldPath(s.(varargin{1}),varargin{2:end});
		else
			bPathExists	= false;
		end
end
