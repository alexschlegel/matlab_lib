function res = Ask(pmt,strPrompt,varargin)
% Group.Prompt.Ask
% 
% Description:	prompt for user input
% 
% Syntax:	res = pmt.Ask(strPrompt,<options>)
% 
% In:
% 	strPrompt	- the prompt to show
%	<options>:
%		mode:		(pmt.mode) the prompt mode (see Group.Prompt.mode)
%		choice:		(<none>) a cell of acceptable choices
%		default:	(<'' if not multi-choice, first choice otherwise>) the
%					default choice
%
% Out:
%	res	- the response
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'mode'	, pmt.mode	  ...
		);
opt.mode	= CheckInput(opt.mode,'mode',{'command_window','ptb_window'});

switch opt.mode
	case 'command_window'
		res	= ask(strPrompt,'dialog',false,varargin{:});
end
