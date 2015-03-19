function b = isoptstruct(opt)
% isoptstruct
% 
% Description:	determine whether opt is an options struct from ParseArgs
% 
% Syntax:	b = isoptstruct(opt)
% 
% Updated: 2015-03-05
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= isstruct(opt) && isfield(opt,'isoptstruct') && opt.isoptstruct;
