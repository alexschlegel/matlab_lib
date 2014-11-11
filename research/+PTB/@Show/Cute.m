function [bAbort,tResponse] = Cute(shw,varargin)
% PTB.Show.Cute
% 
% Description:	show a cute movie loop until user response is detected
% 
% Syntax:	[bAbort,tResponse] = shw.Cute(<options>)
% 
% In:
%	<options>:
%		blank:		(true) true to blank the screen after the subject responds
%		prompt:		(false) the prompt to show below the movie. false to show
%					no prompt
%		fresponse:	(<any key is pressed>) the handle to a function that takes no
%					inputs and returns three outputs:
%						a logical indicating whether to move on
%						a logical indicating whether the movie should be aborted
%						the time associated with the response
%		freset:		(<reset all keys>) a function that takes no inputs and
%					returns no outputs.  use to reset the state of the response
%					test function before we wait for the response.
% 
% Updated: 2012-06-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'blank'		, true				, ...
			'prompt'	, false				, ...
			'fresponse'	, @fResponseDefault	, ...
			'freset'	, @fResetDefault	  ...
			);
	bPrompt		= ~isequal(opt.prompt,false);

%prepare the movie
	cPathCute	= shw.parent.Info.Get('show',{'cute','path'});
	nCute		= numel(cPathCute);
	kCute		= shw.parent.Info.Get('show',{'cute','next'});
	kSequence	= shw.parent.Info.Get('show',{'cute','sequence'});
	
	if kCute>nCute
		kCute	= nCute;
	end
	
	if kCute==0
	%no movies, oops
		shw.Text('<color:red><size:3>RELAX!</size></color>');
	else
		kShow	= kSequence(kCute);
	end
	
	%get the size of the window
		[h,sz,rect,szVA]	= shw.parent.Window.Get('main');
	%show the movie at 1/2 of the minimum screen dimensions
		sCute	= min(szVA)/2;
		yCute	= -(szVA(2)-sCute)/6;
		pCute	= [0 yCute];
	%prompt position
		yPrompt	= sCute/2;
		pPrompt	= [0 yPrompt];
%add a log entry
	shw.AddLog('cute started');
%show the movie
	bEnd	= false;
	
	opt.freset();
	
	while ~bEnd
		if kCute~=0
			shw.parent.Show.Movie.Open(cPathCute{kShow});
			shw.parent.Show.Movie.Play;
		end
		
		while ~bEnd && (kCute==0 || shw.parent.Show.Movie.ShowFrame([],pCute,sCute))
			if kCute~=0
				%show the prompt
					if bPrompt
						shw.Text(opt.prompt,pPrompt);
					end
				%flip
					shw.parent.Window.Flip;
			end
			
			%check for the response
				[bEnd,bAbort,tResponse]	= opt.fresponse();
				
				if bAbort
					return;
				end
		end
		
		if kCute~=0
			shw.parent.Show.Movie.Close;
		end
	end
%update the cute sequence
	kCute	= kCute+1;
	if kCute>nCute
		kSequence	= randomize(kSequence);
		shw.parent.Info.Set('show',{'cute','sequence'},kSequence);
		shw.parent.Info.Set('show',{'cute','next'},1);
	else
		shw.parent.Info.Set('show',{'cute','next'},kCute);
	end
%blank the screen
	if opt.blank
		shw.Blank();
		shw.parent.Window.Flip;
	end
%add a log entry
	shw.AddLog('cute ended',tResponse);

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
