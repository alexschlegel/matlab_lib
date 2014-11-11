function [bAbort,tResponse] = Instructions(shw,str,varargin)
% PTB.Show.Instructions
% 
% Description:	show instructions and wait for the subject to respond
% 
% Syntax:	[bAbort,tResponse] = shw.Instructions(str,<options>)
% 
% In:
%	str	- a string formatted for PTB.Show.Text
%	<options>:
%		window:		('main') the name of the window on which to show the
%					instructions
%		blank:		(false) true to blank the screen after the subject responds
%		figure:		(<none>) an image or handle to a texture to show above the
%					text
%		next:		('continue') a description of what will happen after the
%					subject responds (see the 'prompt' option)
%		prompt:		('Press any <button/key> to <next>.') the prompt to show
%					below the instructions
%		fresponse:	(<any key is pressed>) false to return immediately without
%					flipping or blanking the screen, or the handle to a function
%					that takes no inputs and returns three outputs:
%						a logical indicating whether to move on
%						a logical indicating whether the instructions should be
%							aborted
%						the time associated with the subject's response
%		freset:		(<reset all keys>) a function that takes no inputs and
%					returns no outputs.  use to reset the state of the response
%					test function before we wait for the subject response.
%
% Out:
%	bAbort		- true if the opt.fresponse function aborted
%	tResponse	- the time at which the subject responded
% 
% Updated: 2011-12-22
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'window'	, 'main'			, ...
			'blank'		, false				, ...
			'figure'	, []				, ...
			'next'		, 'continue'		, ...
			'prompt'	, []				, ...
			'fresponse'	, @fResponseDefault	, ...
			'freset'	, @fResetDefault	  ...
			);
	bResponse	= ~isequal(opt.fresponse,false);
	bFlip		= bResponse && isequal(lower(opt.window),'main');
	
	if isempty(opt.prompt)
		strButton	= switch2(shw.parent.Input.type,...
						'keyboard'	, 'key'		, ...
									  'button'	  ...
						);
		
		opt.prompt	= ['Press any ' strButton ' to ' opt.next '.'];
	end
	
	[h,sz,rect,szVA]	= shw.parent.Window.Get(opt.window);

%blank the screen
	shw.Blank('window',opt.window,'fixation',false);
%show the instructions
	ShowInstructions(true);
%wait until the subject responds
	if bResponse
		%reset the keys
			opt.freset();
		
		bNext	= false;
		while ~bNext
			[bNext,bAbort,tResponse]	= opt.fresponse();
			if bAbort
				return;
			end
		end
	else
		bAbort		= false;
		tResponse	= NaN;
	end
%blank the screen
	if bResponse
		if opt.blank
			shw.Blank('window',opt.window);
			
			if bFlip
				shw.parent.Window.Flip;
			end
		else
			ShowInstructions(false);
		end
	end
%add a log entry
	if bResponse
		shw.AddLog('instructions ended',tResponse);
	end

%------------------------------------------------------------------------------%
function ShowInstructions(bPrompt)
	if ~isempty(opt.figure)
		if ischar(opt.figure) || isscalar(opt.figure)
			[hFig,szFig,rectFig,szFigVA]	= shw.parent.Window.Get(opt.figure);
			
			%make sure the figure fits
				if szFigVA(1)>szVA(1)-2
					szFigVA	= szFigVA * (szVA(1)-2)/szFigVA(1);
				end
				if szFigVA(2)>2*szVA(2)/3
					szFigVA	= szFigVA * (2*szVA(2)/3)/szFigVA(2);
				end
			
			pFigure	= [0 -szVA(2)/2+szFigVA(2)/2+1];
			
			shw.Texture(opt.figure,[],pFigure,szFigVA,'window',opt.window);
		else
			szFig	= [size(opt.figure,2) size(opt.figure,1)];
			szFigVA	= shw.parent.Window.px2va(szFig);
			
			%make sure the figure fits
				if szFigVA(1)>szVA(1)-2
					szFigVA	= szFigVA * (szVA(1)-2)/szFigVA(1);
				end
				if szFigVA(2)>szVA(2)/2
					szFigVA	= szFigVA * (szVA(2)/2)/szFigVA(2);
				end
			
			pFigure	= [0 -szVA(2)/2+szFigVA(2)/2+1];
			
			shw.Image(opt.figure,pFigure,szFigVA,'window',opt.window);
		end
		
		pText	= [0 (szFigVA(2)+1)/2];
	else
		pText	= [0 0];
	end
	
	strInstruct	= [reshape(str,1,[]) '\n\n<align:center>' conditional(bPrompt,opt.prompt,' ') '</align>'];
	shw.Text(strInstruct,pText,'window',opt.window);
	
	if bFlip
		shw.parent.Window.Flip(conditional(bPrompt,'instructions',''));
	end
end
%------------------------------------------------------------------------------%
function [bNext,bAbort,tResponse] = fResponseDefault()
	[bAbort,tResponse]	= shw.parent.Input.WaitPressed('any',false);
	
	bNext	= true;
end
%------------------------------------------------------------------------------%
function fResetDefault()
	shw.parent.Input.Pressed('any','reset');
end
%------------------------------------------------------------------------------%

end
