function x = extract(x,dim,k,varargin)
% extract
% 
% Description:	extract a slice from an array
% 
% Syntax:	x = extract(x,dim,k,<options>)
% 
% In:
% 	x	- an array
%	dim	- the dimension from which to extract the slice
%	k	- the index of the slice
%	options:
%		squeeze:	(true) true to squeeze the slice
% 
% Out:
% 	x	- the (squeezed) slice
% 
% Example:	extract(ones(3,3,3),2,2)=ones(3,3)
% 
% Updated: 2010-04-19
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'squeeze'	, true	  ...
		);

%construct the struct for the subsref call
	s.type		= '()';
	s.subs		= repmat({':'},[1 ndims2(x)]);
	s.subs{dim}	= k;
%get the slize
	x	= subsref(x,s);
%squeeze it!
	if opt.squeeze
		x	= squeeze(x);
	end
	