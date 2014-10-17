function b = YesNo(pmt,strPrompt,varargin)
% Group.Prompt.YesNo
% 
% Description:	ask a yes/no question
% 
% Syntax:	b = pmt.YesNo(strPrompt,<options>)
% 
% In:
% 	strPrompt	- the prompt to show
%	<options>:
%		mode:		(pmt.mode) the prompt mode (see Group.Prompt.mode)
%		default:	('y') the default response
%
% Out:
%	b	- the response as a logical
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'mode'		, []	, ...
		'default'	, 'y'	  ...
		);

b	= isequal(pmt.Ask(strPrompt,'mode',opt.mode,'choice',{'y','n'},'default',opt.default),'y');
