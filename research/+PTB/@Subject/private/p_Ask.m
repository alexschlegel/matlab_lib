function p_Ask(sub,strName,strPrompt,varargin)
% p_Ask
% 
% Description:	ask a question about the subject and store the result
% 
% Syntax:	p_Ask(sub,strName,strPrompt,[cChoice]=<none>,[strType]='char',<options>)
% 
% In:
% 	strName		- the name of of the piece of info, must be field name compatible
%	strPrompt	- the prompt for info
%	[cChoice]	- a cell of choices (first one default)
%	[strType]	- the output type, or one of the following:
%					number: store as a number using str2num
%					time:	store as a time
%	<options>:
%		replace:	(true) true to replace existing values.  if false and info
%					already exists, doesn't ask.
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cChoice,strType,opt]	= ParseArgs(varargin,[],'char',...
							'replace'	, true	  ...
							);

if opt.replace || isempty(sub.Get(strName))
	res	= NaN;
	strExtra	= '';
	
	while isnan(res)
		%prompt
			res			= sub.parent.Prompt.Ask([strPrompt strExtra],'choice',cChoice);
			strExtra	= '(???)';
		%format the response
			switch strType
				case 'time'
					res	= FormatTime(res);
				case 'number'
					res	= str2num(res);
				otherwise
					res	= cast(res,strType);
			end
	end
	
	%store it
		sub.Set(strName,res);
end
