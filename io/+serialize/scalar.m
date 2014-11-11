function str = scalar(x,varargin)
% serialize.scalar
% 
% Description:	serialize a scalar value
% 
% Syntax:	str = serialize.scalar(x,<options>)
%
% In:
%	<options>:
%		precision:	(5) the number of decimal places to include
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'precision'	, 5	  ...
		);

str	= num2str(x,opt.precision);
