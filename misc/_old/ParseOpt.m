function opt = ParseOpt(opt,varargin)
% ParseOpt
% 
% Description:	parses a struct of options, adding default values where
%				there are omissions
% 
% Syntax:	opt = ParseOpt(opt,...,'<optionK_name>',optionK,...)
%
% In:
%	opt	- the partially filled option struct
% 
% Out:
%	opt	- opt with omissions filled
%
% Notes: changes all uppercase letter to lowercase and spaces to underscores
%
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isequal(class(opt),'cell')
	opt	= ParseOpt(struct(),opt{:});
end

for k=1:2:numel(varargin)
	varargin{k}	= lower(varargin{k});
	varargin{k}(varargin{k}==' ')	= '_';
	
	if ~isfield(opt,lower(varargin{k})) || isempty(opt.(lower(varargin{k})))
		opt.(lower(varargin{k}))	= varargin{k+1};
	end
end
