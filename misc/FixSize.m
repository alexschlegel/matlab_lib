function s = FixSize(s,varargin)
% FixSize
% 
% Description:	fixes a size argument
% 
% Syntax:	s = FixSize(s,[nd]=2)
%
% In:
%	s		- a size argument passed by the user to a function
%	[nd]	- the number of dimensions the size array should be
% 
% Out:
%	s	- a 1 by nd array with the values of s if s is nd, or filled with s
%		  if s is scalar
%
% Assumptions: assumes s is scalar if it doesn't have size nd
% 
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nd	= ParseArgs(varargin,2);

if numel(s)==1
	s	= s.*ones(1,nd);
else
	s	= reshape(s,1,nd);
end
