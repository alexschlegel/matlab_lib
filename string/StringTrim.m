function str = StringTrim(str,varargin)
% StringTrim
% 
% Description:	trim leading and trailing whitespace (or another character) from
%				str
% 
% Syntax:	str = StringTrim(str,<options>)
%
% In:
%	str	- a string
%	<options>:
%		'char':	(\s) the character to trim
% 
% Out:
%	str	- the trimmed string
% 
% Updated:	2012-11-13
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%speed this up a bit
% opt	= ParseArgsOpt(varargin,...
% 		'char'	, '\s'	  ...
% 		);
	if ~numel(varargin)>1 && isequal(lower(varargin{1}),'char') && ~isempty(varargin{2})
		opt.char	= varargin{2};
	else
		opt.char	= '\s';
	end

%trim leading whitespace
	str	= regexprep(str,['^' opt.char '*'],'');
%trim trailing whitespace
	str	= regexprep(str,[opt.char '*$'],'');
