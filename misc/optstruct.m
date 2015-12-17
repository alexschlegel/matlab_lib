function opt = optstruct(opt,opt_extra)
% optstruct
% 
% Description:	construct an options struct
% 
% Syntax:	opt = optstruct(opt,opt_extra)
% 
% In:
% 	opt			- a struct of options values
%	opt_extra	- a struct of extra options to set as opt.opt_extra
% 
% Out:
% 	opt	- opt as an options struct
% 
% Updated: 2015-12-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt.isoptstruct	= true;
opt.opt_extra	= opt_extra;
