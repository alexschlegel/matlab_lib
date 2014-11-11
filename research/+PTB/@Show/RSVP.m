function [tResponse,tImperative,tWarning,tRSVP,rateRSVP,rateScreen,strRSVP,err,varargout] = RSVP(shw,tImperative,varargin)
% PTB.Show.RSVP
% 
% Description:	show an RSVP stream with imperative and warning stimuli
% 
% Syntax:	[tResponse,tImperative,tWarning,tRSVP,rateRSVP,rateScreen,strRSVP,err,x1,...,xN] = shw.RSVP(tImperative,<options>)
% 
% In:
% 	tImperative	- the time at which the imperative stimulus should be shown,
%				  relative to the start of the sequence
%	<options>:
%		tstart:			(<now>) the PTB.Now format start time
%		tend:			(2000) the time at which to end the RSVP stream, relative
%						to the imperative stimulus
%		durwarn:		(<none>) the duration of the warning stimulus
%		warn:			(false) true to show the warning stimulus
%		fresponse:		('any') either the name of a button or the handle to a
%						function that checks for subject response.  should take
%						no inputs and return at least three outputs: a logical
%						indicating whether the subject responded, a logical
%						indicating whether an error occurred, and the time at
%						which the response was recorded.  any extra outputs are
%						returned in the cells x1 through xN.
%		response:		(true) true to expect a response from the subject
%		rate_rsvp:		(20/3) the target RSVP stream rate, in Hz
%		rate_screen:	(<refreshrate/2>) the target rate for updating the
%						stimulus, in Hz.  the actual update rate will be a
%						multiple of the RSVP rate.
%		fon:			(1) the fraction of each RSVP step during which the
%						RSVP stimulus should be shown
%		height::		(5) the height of the RSVP stimuli, in degrees of visual
%						angle
%		colrsvp:		(<'blue', or rainbow without warning or imperative colors
%						for color cycle RSVP streams>) the color of the RSVP
%						stream.  for color cycle RSVP streams, a cell of colors
%		colwarn:		('yellow') the color of the warning stimulus
%		colimp:			('green') the color of the imperative stimulus
%		charimp:		('G') the imperative character
%		charrsvp:		(<all but charimp>) a character array of RSVP stream
%						characters
%		colorjitter:	(true) true to jitter the brightness of the stimulus
%						color on each presentation
%		colorcycle:		(false) true to continuously cycle through RSVP colors
%		erroreturn:		(true) true to return if an error occurs
%		fixation:		(true) true to show the fixation dot
% 
% Out:
% 	tResponse	- the time at which the subject's first response was recorded
%	tImperative	- the time at which the imperative was shown
%	tWarn		- the time at which the warning stimulus began
%	tRSVP		- the time at which each RSVP stimulus was shown
%	rateRSVP	- the actual RSVP rate
%	rateScreen	- the actual screen refresh rate
%	strRSVP		- the RSVP stream
%	err			- the type of error that occurred:
%					0:	no error
%					1:	subject responded but shouldn't have
%					2:	subject didn't respond but should have
%					3:	subject responded before the imperative stimulus
%					4:	subject responded more than once
%					5:	fresponse indicated that an error occurred
%	xK			- a cell of the Kth extra outputs from fresponse during calls in
%				  which the subject had responded.  if a button name is passed as
%				  fresponse, then x1 is the state index of the button(s) that
%				  were pressed.
% 
% Updated: 2012-03-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

opt	= ParseArgs(varargin,...
		'tstart'		, PTB.Now						, ...
		'tend'			, 2000							, ...
		'durwarn'		, 2000							, ...
		'warn'			, false							, ...
		'fresponse'		, 'any'							, ...
		'response'		, true							, ...
		'rate_rsvp'		, 20/3							, ...
		'rate_screen'	, PTBIFO.window.refreshrate/2	, ...
		'fon'			, 1								, ...
		'height'		, 5								, ...
		'colrsvp'		, []							, ...
		'colwarn'		, 'yellow'						, ...
		'colimp'		, 'green'						, ...
		'charimp'		, 'G'							, ...
		'charrsvp'		, []							, ...
		'colorjitter'	, false							, ...
		'colorcycle'	, false							, ...
		'errorreturn'	, true							, ...
		'fixation'		, true							  ...
		);

if ischar(opt.fresponse)
	strResponse		= opt.fresponse;
	opt.fresponse	= @Response_Default;
end
if isempty(opt.colrsvp)
	if opt.colorcycle
		opt.colrsvp	= setdiff({'red','orange','yellow','green','cyan','blue','purple'},{opt.colwarn; opt.colimp});
	else
		opt.colrsvp	= 'blue';
	end
end
if isempty(opt.charrsvp)
	opt.charrsvp	= setdiff('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',opt.charimp);
end

opt.colrsvp	= ForceCell(opt.colrsvp);

%make the RSVP rate divisible by the screen refresh rate
	rateRSVP	= PTBIFO.window.refreshrate/round(PTBIFO.window.refreshrate/opt.rate_rsvp);
%fix the screen refresh rate
	rateScreen	= round(opt.rate_screen/rateRSVP)*rateRSVP;
%fix the imperative time
	tPerRSVP	= 1000/rateRSVP;
	tImperative	= round(tImperative/tPerRSVP)*tPerRSVP;
%get the times at which each stimulus should be shown
	durRSVP	= tImperative + opt.tend;
	tRSVP	= GetInterval(0,durRSVP,tPerRSVP,'stepsize')';
	nRSVP	= numel(tRSVP);
	
	tWarn	= tImperative - opt.durwarn;
	kWarn	= find(tRSVP>=tWarn,1);
%get the stimuli to show
	strRSVP	= randFrom(opt.charrsvp,[nRSVP 1],'unique',false,'repeat',false);
	
	bImperative				= tRSVP==tImperative;
	strRSVP(bImperative)	= opt.charimp;
%get the character colors
	colRSVP	= cellfun(@(col) shw.parent.Color.Get(col),opt.colrsvp,'UniformOutput',false);
	colWarn	= shw.parent.Color.Get(opt.colwarn);
	colImp	= shw.parent.Color.Get(opt.colimp);
	
	if opt.colorcycle
	%choose colors for each cycle
		if opt.warn
		%sync the color cycle with the warning
			tCycleStart	= tImperative - opt.durwarn*(1+ceil(tImperative/opt.durwarn));
		else
			tCycleStart	= -opt.durwarn + randBetween(-opt.durwarn,0);
		end
		
		tCycleEnd	= opt.durwarn*(1+ceil(durRSVP/opt.durwarn));
		
		tColor		= GetInterval(tCycleStart,tCycleEnd,opt.durwarn,'stepsize')';
		nColor		= numel(tColor);
		bColorCycle	= true(nColor,1);
		
		colRSVP	= randFrom(colRSVP,[nColor 1],'unique',false,'repeat',false);
		
		if opt.warn
			bColWarn			= tColor==tWarn;
			colRSVP{bColWarn}	= colWarn;
		end
		
		colRSVP	= cat(1,colRSVP{:});
	elseif opt.warn
	%split between RSVP and warn colors
		tColor		=	[
							0
							tWarn
							tImperative
						];
		bColorCycle	=	[
							false
							true
							false
						];
		colRSVP		=	[
							colRSVP{1}
							colWarn
							colRSVP{1}
						];
	else
	%just the RSVP colors
		tColor		= 0;
		bColorCycle	= false;
		colRSVP		= colRSVP{1};
	end
%prepare the image to mask
	colBack	= shw.parent.Color.Get('background');
	sChar	= size(PTBIFO.show.char.im);
	imChar	= repmat(reshape(colBack,1,1,4),sChar(1:2));
	
	hChar	= opt.height;
	wChar	= opt.height * sChar(2)/sChar(1);
%number of extra outputs
	nOutExtra	= max(0,nargout - 8);
%prepare the outputs
	tResponse	= NaN;
	err			= 0;
	cOutExtra	= cell(nOutExtra,1);
	
%show the sequence
	tStart	= opt.tstart;
	tEnd	= tStart + durRSVP;
	
	kCharLast	= 0;
	
	nFlipStart	= PTBIFO.window.flips;
	
	[tStart,tEnd,tChar,bAbort] = shw.Loop(@ShowRSVP,rateScreen,...
										'tunit'			, 'ms'								, ...
										'tbase'			, 'sequence'						, ...
										'tstart'		, tStart							, ...
										'tend'			, tEnd								, ...
										'fwait'			, @fWait							, ...
										'wait_priority'	, PTB.Scheduler.PRIORITY_CRITICAL	, ...
										'return'		, 'manual'							, ...
										'fixation'		, opt.fixation						  ...
										);
%blank the screen
	shw.Blank('fixation',opt.fixation);
	shw.parent.Window.Flip;
%process the output
	kImperative	= find(tRSVP==tImperative);
	if kImperative<=numel(tChar)
		tImperative	= tChar{kImperative};
	else
		tImperative	= NaN;
	end
	
	if opt.warn
		if kWarn<=numel(tChar)
			tWarning	= tChar{kWarn};
		else
			tWarning	= NaN;
		end
	else
		tWarning	= NaN;
	end
	
	if opt.response && err==0 && isnan(tResponse)
		err	= 2;
	end
	
	tRSVP		= cell2mat(tChar);
	
	nFlipEnd	= PTBIFO.window.flips;
	rateRSVP	= 1000*(numel(tRSVP)-1)/(tRSVP(end)-tRSVP(1));
	rateScreen	= 1000*(nFlipEnd-nFlipStart-1)/(tEnd-tStart);
	
	varargout	= cOutExtra;
	
	if isequal(opt.fresponse,@Response_Default) && numel(varargout)>=1
		if ~isempty(varargout{1})
			varargout{1}	= varargout{1}{1};
		else
			varargout{1}	= NaN;
		end
	end


%------------------------------------------------------------------------------%
function bReport = ShowRSVP(tNow,tNext)
	bReport	= false;
	
	fWithin	= mod(tNext,tPerRSVP)/tPerRSVP;
	
	%should we show the character?
		bShow	= fWithin<=opt.fon;
	
	if bShow
	%which character/color should we show?
		if tNext>=tImperative && tNext<=tImperative+tPerRSVP
		%show the imperative
			kChar		= -1;
			strChar		= opt.charimp;
			colCharFrom	= colImp;
			colCharTo	= colImp;
			fCycle		= 1;
		else
			kChar	= find(tRSVP<=tNext,1,'last');
			strChar	= strRSVP(kChar);
			
			kColor	= find(tColor<=tNext,1,'last');
			
			if bColorCycle(kColor)
				colCharFrom	= colRSVP(kColor-1,:);
				colCharTo	= colRSVP(kColor,:);
				fCycle		= max(0,min(1,(tNext-tColor(kColor))./(tColor(kColor+1)-tColor(kColor))));
			else
				colCharFrom	= colRSVP(kColor,:);
				colCharTo	= colRSVP(kColor,:);
				fCycle		= 1;
			end
		end
		
		if kChar~=kCharLast
			bReport	= true;
		end
		kCharLast	= kChar;
		
		ShowCharacter(strChar,colCharFrom,colCharTo,fCycle);
	else
		shw.Blank('fixation',false);
	end
end
%------------------------------------------------------------------------------%
function ShowCharacter(strChar,colFrom,colTo,fCycle)
	if opt.colorjitter
		colFrom	= JitterColor(colFrom);
		colTo	= JitterColor(colTo);
	end
	
	%show the new color
		shw.Image(reshape(colTo,1,1,4),[],[wChar hChar]);
	%show the remainder of the old color
		if fCycle<1
			shw.Image(reshape(colFrom,1,1,4),[],[wChar hChar*(1-fCycle)]);
		end
	%show the character mask
		kMask			= PTBIFO.show.char.char2k(strChar);
		imChar(:,:,4)	= 255*~PTBIFO.show.char.im(:,:,kMask);
		
		shw.Image(imChar,[],[wChar hChar]);
end
%------------------------------------------------------------------------------%
function col = JitterColor(col)
	hsl			= rgb2hsl(col(1:3));
	hsl(3)		= randBetween(64,192);
	col(1:3)	= hsl2rgb(hsl);
end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function bAbort = fWait(tNow,tNext)
	cOutExtraCur										= cell(nOutExtra,1);
	[bRespond,bError,tResponseCur,cOutExtraCur{:}]	= opt.fresponse();
	bOutput												= ~cellfun(@isempty,cOutExtraCur);
	cOutExtra(bOutput)									= cellfun(@(c,x) [c;{x}],cOutExtra(bOutput),cOutExtraCur(bOutput),'UniformOutput',false);
	
	if bRespond
		if tNow>=tImperative && ~opt.response
		%shouldn't have responded
			err	= 1;
		elseif tNow<tImperative
		%responded too early
			err	= 3;
		elseif ~isnan(tResponse)
		%responded more than once
			err	= 4;
		else
		%juuuuust right
			tResponse	= tResponseCur;
		end
	end
	
	if bError
		err	= 5;
	end
	
	bAbort	= err~=0 && opt.errorreturn;
end
%------------------------------------------------------------------------------%
function [bRespond,bError,tRespond,kButton] = Response_Default()
	[bRespond,bError,tRespond,kButton] = shw.parent.Input.DownOnce(strResponse);
end
%------------------------------------------------------------------------------%

end
