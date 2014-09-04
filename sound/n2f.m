function f = n2f(varargin)
% n2f
% 
% Description:	convert notes to frequencies
% 
% Syntax:	f = n2f([s]=<chromatic>,n)
% 
% In:
% 	[s]	- a scale returned by CreateScale
%	n	- a note or cell of notes
% 
% Out:
% 	f	- an array of frequencies corresponding to the specified notes
% 
% Updated: 2010-11-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent sDefault;

if nargin==0
	f	= [];
elseif nargin==1
	if isempty(sDefault)
		sDefault	= CreateScale;
	end
	s	= sDefault;
	n	= varargin{1};
else
	s	= varargin{1};
	n	= varargin{2};
end

f	= cell2mat(s(n));
