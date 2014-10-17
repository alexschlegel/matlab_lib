function res = Ask(pmt,strPrompt,varargin)
% PTB.Prompt.Ask
% 
% Description:	prompt for user input
% 
% Syntax:	res = pmt.Ask(strPrompt,<options>)
% 
% In:
% 	strPrompt	- the prompt to show
%	<options>:
%		mode:		(pmt.mode) the prompt mode (see PTB.Prompt.mode)
%		choice:		(<none>) a cell of acceptable choices
%		default:	(<'' if not multi-choice, first choice otherwise>) the
%					default choice
%
% Out:
%	res	- the response
% 
% Updated: 2012-02-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'mode'	, pmt.mode	  ...
		);
opt.mode	= CheckInput(opt.mode,'mode',{'command_window','ptb_window'});

switch opt.mode
	case 'command_window'
		bKeyDisabled	= pmt.parent.Info.Get('experiment',{'disable','key'});
		
		if bKeyDisabled
			ListenChar(1);
		end
		
		res	= ask(strPrompt,'dialog',false,varargin{:});
		
		if bKeyDisabled
			ListenChar(2);
		end
	case 'ptb_window'
		res	= pmt.parent.Show.Prompt(strPrompt,varargin{:});
end
