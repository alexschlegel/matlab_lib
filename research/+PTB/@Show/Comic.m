function [bAbort,tResponse] = Comic(shw,varargin)
% PTB.Show.Comic
% 
% Description:	show a comic
% 
% Syntax:	[bAbort,tResponse] = shw.Comic(<options>)
% 
% In:
%	<options>:
%		window:		('main') the name of the window on which to show the image
%		comic:		(<auto>) the comic to show
%		blank:		(true) true to blank the screen after the subject responds
%		prompt:		('Press any <button/key> to continue') the prompt to show
%					below the comic
%		fresponse:	(<any key is pressed>) false to return immediately without
%					flipping or blanking the screen, or the handle to a function
%					that takes no inputs and returns three outputs:
%						a logical indicating whether to move on
%						a logical indicating whether the comic should be aborted
%						the time associated with the subject's response
%		freset:		(<reset all keys>) a function that takes no inputs and
%					returns no outputs.  use to reset the state of the response
%					test function before we wait for the subject response.
% 
% Updated: 2013-04-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'window'	, 'main'			, ...
			'comic'		, []				, ...
			'blank'		, true				, ...
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
		
		opt.prompt	= ['Press any ' strButton ' to continue.'];
	end

%show the comic
	%get the size of the window
		[h,sz,rect,szVA]	= shw.parent.Window.Get(opt.window);
	%load the comic
		
	%show the comic at 5/6 of the minimum screen dimensions
		sComic	= 5*min(szVA)/6;
		yComic	= -(szVA(2)-sComic)/6;
		pComic	= [0 yComic];
		
		cPathComic	= shw.parent.Info.Get('show',{'comic','path'});
		nComic		= numel(cPathComic);
		
		bManual	= ~isempty(opt.comic);
		
		if bManual
			kComic		= shw.parent.Info.Get('show',{'comic','next'});
			kSequence	= shw.parent.Info.Get('show',{'comic','sequence'});
			
			if kComic>nComic
				kComic	= nComic;
			end
		end
		
		if ~bManual && isempty(kComic==0)
		%no comics, oops
			shw.Text('No comics, sorry!',pComic,'window',opt.window);
		else
			kShow	= unless(opt.comic,kSequence(kComic));
			
			try
				im	= imread(cPathComic{kShow});
				shw.Image(im,pComic,sComic,'window',opt.window);
			catch me
				shw.Text('No comics, sorry!',pComic,'window',opt.window);
			end
		end
	%show the prompt
		yPrompt	= sComic/2;
		pPrompt	= [0 yPrompt];
		
		shw.Text(opt.prompt,pPrompt,'window',opt.window);
	
	if bFlip
		shw.parent.Window.Flip('comic');
	end
%update the comic sequence
	if ~bManual
		kComic	= kComic+1;
		if kComic>nComic
			kSequence	= randomize(kSequence);
			shw.parent.Info.Set('show',{'comic','sequence'},kSequence);
			shw.parent.Info.Set('show',{'comic','next'},1);
		else
			shw.parent.Info.Set('show',{'comic','next'},kComic);
		end
	end
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
	if bResponse && opt.blank
		shw.Blank('window',opt.window);
		
		if bFlip
			shw.parent.Window.Flip;
		end
	end
%add a log entry
	if bResponse
		shw.AddLog('comic ended',tResponse);
	end

%------------------------------------------------------------------------------%
function [bNext,bAbort,tResponse] = fResponseDefault()
	[bNext,bAbort,tResponse]	= shw.parent.Input.Pressed('any',false);
end
%------------------------------------------------------------------------------%
function fResetDefault()
	shw.parent.Input.Pressed('any','reset');
end
%------------------------------------------------------------------------------%

end
