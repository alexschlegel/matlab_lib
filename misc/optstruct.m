function opt = optstruct(varargin)
% optstruct
% 
% Description:	construct an options struct
% 
% Syntax:	opt = optstruct([opt],[opt_extra])
% 
% In:
% 	opt			- a struct of options values
%	opt_extra	- a struct of extra options
% 
% Out:
% 	opt	- opt as an opt struct
% 
% Updated: 2015-04-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin>0
	opt	= varargin{1};
	
	if isempty(opt)
		opt	= struct;
	end
	
	opt.isoptstruct	= true;
	
	if nargin>1
		opt.opt_extra	= varargin{2};
	elseif ~isfield(opt,'opt_extra')
		opt.opt_extra	= struct;
	end
else
	opt	= optstruct(struct);
end