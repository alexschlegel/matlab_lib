function [bAbort,tResponse] = Short(shw,varargin)
% PTB.Show.Short
% 
% Description:	show Pixar Shorts until the right key is pressed
% 
% Syntax:	shw.Short()
% 
% Updated: 2012-12-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%prepare a keyboard object
	key	= PTB.Device.Input.Keyboard(shw.parent);
	key.Start;
%prepare the short
	cPathShort	= shw.parent.Info.Get('show',{'short','path'});
	nShort		= numel(cPathShort);
	kShort		= shw.parent.Info.Get('show',{'short','next'});
	kSequence	= shw.parent.Info.Get('show',{'short','sequence'});
	
	if kShort>nShort
		kShort	= nShort;
	end
	
	%get the size of the window
		[h,sz,rect,szVA]	= shw.parent.Window.Get('main');
	%show the movie full screen
		sShort	= max(szVA);
		pShort	= [0 0];
%add a log entry
	shw.AddLog('short started');
	
	disp('waiting for right key press');
%show the movie
	bEnd	= false;
	
	if kShort==0
		shw.Text('<color:electric>relax</color>');
		shw.parent.Window.Flip;
	end
	
	while ~bEnd
		if kShort~=0
			kShow	= kSequence(kShort);
			
			shw.parent.Show.Movie.Open(cPathShort{kShow});
			shw.parent.Show.Movie.Play;
		end
		
		while ~bEnd && (kShort==0 || shw.parent.Show.Movie.ShowFrame([],pShort,sShort))
			if kShort~=0
				shw.parent.Window.Flip;
			end
			
			%check for the response
				bEnd	= key.Pressed('right',false);
		end
		
		if kShort~=0
			shw.parent.Show.Movie.Close;
		end
		
		%update the short sequence
			kShort	= kShort+1;
			if kShort>nShort
				kSequence	= randomize(kSequence);
				shw.parent.Info.Set('show',{'short','sequence'},kSequence);
				shw.parent.Info.Set('show',{'short','next'},1);
			else
				shw.parent.Info.Set('show',{'short','next'},kShort);
			end
	end
%blank the screen
	shw.Blank();
	shw.parent.Window.Flip;
%add a log entry
	shw.AddLog('short ended');
