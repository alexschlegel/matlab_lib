function [r,tResponse] = Prompt(shw,strPrompt,varargin)
% PTB.Show.Prompt
% 
% Description:	show a prompt for input and return the response
% 
% Syntax:	[r,tResponse] = shw.Prompt(strPrompt,<options>)
% 
% In:
%	strPrompt	- a string formatted for PTB.Show.Text
%	<options>:
%		window:		('main') the name of the window on which to show the
%					instructions.  if this isn't 'main' then the function won't
%					wait for input
%		blank:		(true) true to blank the screen after the subject responds
%		figure:		(<none>) an image or handle to a texture to show above the
%					text
%		type:		('string') the type of response to collect.  either 'string'
%					or 'number'
%		choice:		(<none>) a cell of acceptable choices
%		default:	(<'' if not multi-choice, first choice otherwise>) the
%					default choice
%
% Out:
%	r			- the response
%	tResponse	- the time at which the subject responded
% 
% Updated: 2011-12-22
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'window'	, 'main'	, ...
			'blank'		, true		, ...
			'figure'	, []		, ...
			'type'		, 'string'	, ...
			'choice'	, {}		, ...
			'default'	, ''		  ...
			);
	bMulti	= ~isempty(opt.choice);
	bWait	= isequal(opt.window,'main');
	bFlip	= bWait;
	
	opt.type	= CheckInput(opt.type,'type',{'string','number'});
	cKeyValid	= switch2(opt.type,...
					'string'	, num2cell(1:255)			, ...
					'number'	, num2cell([45:46 48:57])	  ...
					);
	
	if isempty(opt.default) && bMulti
		if iscell(opt.choice)
			opt.default	= opt.choice{1};
		else
			opt.default	= opt.choice(1);
		end
	end
	
	[h,sz,rect,szVA]	= shw.parent.Window.Get(opt.window);
	
	
%make sure the keyboard is disabled
	if bWait && ~shw.parent.Info.Get('experiment',{'disable','key'})
		ListenChar(2);
	end
%show the instructions
	if bMulti
	%multiple choice
		switch opt.type
			case 'string'
				cChoice	= opt.choice;
				
				%get the responses that will match
					cMatch			= [reshape(lower(cChoice),1,[]) {''}];
				%get the position of the default choice
					[bDefault,kDefault]	= ismember(lower(opt.default),lower(opt.choice));
					
					if bDefault
						cChoice{kDefault}	= ['[' cChoice{kDefault} ']'];
					end
			case 'number'
				cChoice	= conditional(iscell(opt.choice),opt.choice,num2cell(opt.choice));
				cChoice	= cellfun(@num2str,cChoice,'UniformOutput',false);
				
				%get the responses that will match
					if iscell(opt.choice)
						cMatch			= [reshape(cellfun(@todouble,opt.choice),1,[]) NaN];
					else
						cMatch			= [reshape(opt.choice,1,[]) NaN];
					end
				%get the position of the default choice
					kDefault	= find(cMatch==todouble(opt.default),1);
					
					if ~isempty(kDefault) && kDefault<=numel(cChoice)
						cChoice{kDefault}	= ['[' cChoice{kDefault} ']'];
					end
		end
		
		%prompt for the very first time
			str				= [reshape(strPrompt,1,[]) '\n\n<align:center>(' join(cChoice,',') ')>> '];
			[r,tResponse]	= DoPrompt(str);
		if bWait
		%prompt again until we get a match
			[r,bMatch]	= GetMatch(r,cMatch,opt.default);
			while ~bMatch
				str				= [reshape(strPrompt,1,[]) '\n\n<align:center>(CHOOSE FROM: ' join(cChoice,',') ')>> '];
				[r,tResponse]	= DoPrompt(str);
				[r,bMatch]		= GetMatch(r,cMatch,opt.default);
			end
		end
	else
	%take whatever we get
		str				= [reshape(strPrompt,1,[]) '\n\n<align:center>>> '];
		[r,tResponse]	= DoPrompt(str);
	end
%enable the keyboard if we disabled it
	if bWait && ~shw.parent.Info.Get('experiment',{'disable','key'})
		ListenChar(1);
	end
%blank the screen
	if bWait && opt.blank
		shw.Blank('window',opt.window);
		
		if bFlip
			shw.parent.Window.Flip;
		end
	end
%add a log entry
	if bWait
		shw.AddLog('prompt ended',tResponse);
	end

%------------------------------------------------------------------------------%
function [r,tResponse] = DoPrompt(str)
	[r,tResponse]	= deal(NaN);
	
	ShowPrompt(str,true);
	
	%collect the response
		if bWait
			%flush the key events
				FlushEvents('keyDown');
			
			strResponse	= '';
			while true
				[err,tResponse,kKey]	= shw.Key.WaitDownOnce('any',false);
				chr						= shw.Key.key2char(kKey,shw.Key.Down('shift',false));
				
				switch uint8(chr)
					case 10			%enter
						break;
					case 8			%backspace
						strResponse	= strResponse(1:end-1);
					case cKeyValid
						strResponse	= [strResponse chr];
				end
				
				ShowPrompt([str strResponse],false);
			end
			
			%process the response
				switch opt.type
					case 'number'
						r	= unless(str2num(strResponse),NaN);
					otherwise
						r	= strResponse;
				end
		end
end
%------------------------------------------------------------------------------%
function ShowPrompt(str,bLog)
%show the prompt
	if ~isempty(opt.figure)
		if ischar(opt.figure) || isscalar(opt.figure)
			[hFig,szFig,rectFig,szFigVA]	= shw.parent.Window.Get(opt.figure);
			
			%make sure the figure fits
				if szFigVA(1)>szVA(1)-2
					szFigVA	= szFigVA * (szVA(1)-2)/szFigVA(1);
				end
				if szFigVA(2)>szVA(2)/2
					szFigVA	= szFigVA * (szVA(2)/2)/szFigVA(2);
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
	
	shw.Text([str '</align>'],pText,'window',opt.window);

	if bFlip
		shw.parent.Window.Flip(conditional(bLog,'prompt',''));
	end
end
%------------------------------------------------------------------------------%
function [r,bMatch] = GetMatch(r,cMatch,xDefault)
	switch class(cMatch)
		case 'cell'
			[bMatch,kMatch]	= ismember(lower(r),cMatch);
			
			if bMatch
			%make sure the response looks like one of the choices
				if isempty(r)
					r	= xDefault;
				else
					r	= cMatch{kMatch};
				end
			else
				r		= '';
				kMatch	= [];
			end
		otherwise
			kMatch	= find(r==cMatch | (isnan(r) & isnan(cMatch)),1);
			bMatch	= ~isempty(kMatch);
			
			if bMatch
				if isnan(r)
					r	= xDefault;
				else
					r	= cMatch(kMatch);
				end
			else
				r	= NaN;
			end
	end
end
%------------------------------------------------------------------------------%


end
