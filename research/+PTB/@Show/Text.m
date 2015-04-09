function pNew = Text(shw,str,varargin)
% PTB.Show.Text
% 
% Description:	show text
% 
% Syntax:	pNew = shw.Text(str,[p]=<center/top-left>,[w]=<screen>-2,[a]=0,<options>)
% 
% In:
%	str	- a string, possibly with some simple markup.  markup is denoted HTMLish
%		  as <blah>text here</blah>, where "blah" is one of the following:
%				family:<x>:	the font family of the text
%				size:<x>:	the size of the text, in degrees of visual angle for
%							the letter m
%				style:<x>:	the style of the text.  <x> is one or more of the
%					following, comma-separated: normal, bold, italic, underline,
%					outline condense, extend.
%				align:<x>:	the text-alignment, either left, center, or right
%				color:<x>:	the text color (see PTB.Color)
%				back:<x>:	the background color, same format as the text color
%		  see PTB.Show.Start for default text properties.
%		  to show < and >, escape them with a backslash (e.g. \<)
%		  \n inserts a line break.
%	[p]	- the (x,y) coordinates of the text, in degrees of visual angle
%	[w]	- the maximum width of text, in degrees of visual angle
%	[a]	- the rotation of the text about its center, in clockwise degrees from
%		  vertical
%	<options>:
%		window:			('main') the name of the window on which to show the
%						text
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		border:			(false) true to show a border around the text
%		border_color:	('black') the border color
%		border_size:	(1/6) the border thickness, in degrees of visual angle
% 
% Out:
%	pNew	- the new position at which to continue text
% 
% Updated: 2015-04-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'center'		, true		, ...
						'border'		, false		, ...
						'border_color'	, 'black'	, ...
						'border_size'	, 1/6		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<3 || (isnumeric(varargin{1}) && (nargin<4 || (isnumeric(varargin{2}) && (nargin<5 || (isnumeric(varargin{3}) && nargin<6)))))
	%if nargin<6 && (nargin<3 || isnumeric(varargin{1})) && (nargin<4 || isnumeric(varargin{2})) && (nargin<5 || isnumeric(varargin{3}))
		opt	= optDefault;
		
		[p,w,a]	= ParseArgs(varargin,[0 0],[],0);
	else
		[p,w,a,opt]	= ParseArgs(varargin,[0 0],[],0,cOptDefault{:});
	end

[h,sz,rect,szVA]	= shw.parent.Window.Get(opt.window);

w	= unless(w,szVA(1)-2);
w	= round(shw.parent.Window.va2px(w));

%parse the text into blocks of calls to DrawText
	%add a new line at the end of alignment blocks
		str	= regexprep(str,'</align>(?!\\n|$)','</align>\\n');
		str	= regexprep(str,'(?<!^|\\n|</align>)<align','\\n<align');
	
	%parse the markup
		sDefault		= shw.parent.Info.Get('show','text');
		[cText,sStyle]	= ParseSimpleMarkup(str,'default',sDefault);
		nStyle			= numel(cText);
		
		if nStyle==0
			pNew	= p;
			return;
		end
	%make the size numerical and get the correct font size
		if iscell(sStyle.size)
			sStyle.size	= cellfun(@todouble,sStyle.size);
		end
		[sStyle.size,sStyle.pxH,sStyle.pxB,sStyle.pxW]	= GetFontSize(sStyle.family,sStyle.size);
	%get the RGB color of each text color
		sStyle.color	= cellfun(@(x) shw.parent.Color.Get(x),sStyle.color,'UniformOutput',false);
	%get the RGB color of each background color
		sStyle.back	= cellfun(@(x) shw.parent.Color.Get(x),sStyle.back,'UniformOutput',false);
	%transform the style selection to fit Screen's required format (see
	%Screen('TextStyle?');
		cStyleName	= {'bold','italic','underline','outline','condense','extend'};
		xAdd		= [1 2 4 8 32 64];
		nName		= numel(xAdd);
		
		cStyles			= sStyle.style;
		sStyle.style	= zeros(nStyle,1);
		for kS=1:nStyle
			for kN=1:nName
				if ~isempty(strfind(cStyles{kS},cStyleName{kN}))
					sStyle.style(kS)	= sStyle.style(kS) + xAdd(kN);
				end
			end
		end
	%split into words
		cStyle	= num2cell(restruct(sStyle));
		cWord	= cellfun(@(s) split(s,'\s+','withdelim',true),cText,'UniformOutput',false);
		cStyle	= cellfun(@(w,s) repmat({s},size(w)),cWord,cStyle,'UniformOutput',false);
		
		cWord	= cat(1,cWord{:});
		cStyle	= cat(1,cStyle{:});
		
		nText			= numel(cWord);
	
%draw the text
	%first draw to the hidden window
		hHidden	= shw.parent.Window.Get('hidden');
		shw.Blank('window','hidden');
		[pText,sText,rectHidden,rectShow]	= DrawText;
	%now draw onto the window with proper rotation
		Screen('DrawTexture',h,hHidden,rectHidden,rectShow,a,0);
%add a frame
	if opt.border
		shw.Frame(opt.border_color,sText,opt.border_size,pText-sText,a,...
				'window'	, opt.window	, ...
				'center'	, false			  ...
				);
	end

pNew	= pText;


%------------------------------------------------------------------------------%
function [pText,sText,rectHidden,rectShow] = DrawText
	if nText==0
		pText		= p;
		sText		= [0 0];
		rectHidden	= [0 0 0 0];
		rectShow	= [0 0 0 0];
		
		return;
	end
	
	%open a texture for drawing each line
		hTemp	= shw.parent.Window.OpenTexture('showtext_line');
		colTemp		= shw.parent.Color.Get('none');
		%imTexture	= repmat(reshape(colTemp,1,1,[]),[sz(2) sz(1) 1]);
		%hMain		= shw.parent.Window.Get('main');
		%hTemp		= Screen('MakeTexture',hMain,imTexture);
	
	[pText,pLine]	= deal([0 0]);
	hLine			= cStyle{1}.pxH;
	wLine			= 0;
	pLeft			= 0;
	wText			= 0;
	bFlushed		= true;
	for kT=1:nText
		if isequal(cWord{kT},'\n')
		%we're just a new line
			FlushText(cStyle{max(1,kT-1)});
		else
		%draw the text
			DrawOne(cWord{kT},cStyle{kT});
		end
	end
	
	FlushText(cStyle{nText});
	
	pPx	= shw.parent.Window.va2px(p);
	
	sText		= [wText pText(2)];
	pText		= [pPx(1)+pLeft+wLine pPx(2)+pText(2)-hLine];
	rectHidden	= [0 0 w sText(2)];
	
	if opt.center
		rectShow	= [sz/2+pPx-[w sText(2)]/2 sz/2+pPx+[w sText(2)]/2];
	else
		rectShow	= [pPx pPx+[w sText(2)]];
	end
	
	%close the texture
		%Screen('Close',hTemp);
		shw.parent.Window.CloseTexture('showtext_line');
	
	function DrawOne(str,style)
	%draw one bit of text on the temporary texture
		Screen('TextFont',hTemp,style.family);
		Screen('TextSize',hTemp,style.size);
		Screen('TextStyle',hTemp,style.style);
		
		if style.back(4)>0
			Screen('Preference','TextAlphaBlending',0);%1 doesn't seem to be needed (in Linux)
		else
			Screen('Preference','TextAlphaBlending',0);
		end
		
		%get the height of an M, an m, and a g
			if bFlushed
				bFlushed	= false;
				hLine		= style.pxH;
			else
				hLine	= max(hLine,style.pxH);
			end
		%get the size of the text
			[rectRelCur,rectCur]	= Screen('TextBounds',hTemp,str,pLine(1),pLine(2));
		%if this will push us over the edge, start a new line
			if rectCur(3)>w-1 && pLine(1)~=0
				FlushText(style);
				
				xNext	= rectRelCur(3);
			else
				xNext	= rectCur(3);
			end
			
		%draw the text on the temporary texture
			Screen('DrawText',hTemp,str,pLine(1),pLine(2)+style.pxB,style.color,style.back,1);
			pLine(1)	= xNext;
			%pLine(1)	= Screen('DrawText',hTemp,str,pLine(1),pLine(2)+style.pxB,style.color,style.back,1);
		
		%add spaces to the end
			[kStart,kEnd]	= regexp(str,'\s+$','start','end');
			if ~isempty(kStart) && ~isempty(kEnd)
				nSpace		= kEnd-kStart+1;
				pLine(1)	= pLine(1) + nSpace*(0.75*style.pxW);
			end
	end
	function FlushText(style)
	%transfer the temporary texture to the hidden window
		bFlushed	= true;
		
		wLine		= pLine(1)+4;
		rectTemp	= [0 0 wLine hLine];
		
		switch style.align
			case 'left'
				pLeft	= 0;
			case 'center'
				pLeft	= (w-wLine)/2;
			case 'right'
				pLeft	= w - wLine;
		end
		rectHidden	= [pLeft pText(2) pLeft+wLine pText(2)+hLine];
		wText		= max(wText,pLeft+wLine);
		
		%draw temporary to hidden
			Screen('DrawTexture',hHidden,hTemp,rectTemp,rectHidden);
		%blank the temporary
			Screen('BlendFunction',hTemp,GL_ONE,GL_ZERO);
			Screen('FillRect',hTemp,colTemp);
			Screen('BlendFunction',hTemp,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
		
		pText(2)	= pText(2) + 5*hLine/4;
		pLine		= [0 0];
	end
end
%------------------------------------------------------------------------------%
function [s,pxH,pxB,pxW] = GetFontSize(strFamily,va)
% get the font size for Screen so that the letter m of the specified font family
% will be va degrees of visual angle wide
%	s:		the input to Screen('TextSize')
%	pxH:	the maximum height of a line of text from bottom to top
%	pxB:	the offset of the baseline from the maximum height
%	pxW:	the width of the letter m
	persistent cFamily mFamily;
	
	if isempty(cFamily)
		cFamily	= {};
		mFamily	= [];
	end
	
	[bExist,kFamily]	= ismember(strFamily,cFamily);
	
	bCalc	= ~bExist;
	if any(bCalc)
	%calculate maps for non-existent families
		strFamilyCalc	= unique(strFamily(~bExist));
		nFamilyCalc		= numel(strFamilyCalc);
		
		for kF=1:nFamilyCalc
			%get some sizes
				fs	= [50 100];
				ds	= fs(2)-fs(1);
				
				fOrig	= Screen('TextFont',h,strFamily{kF});
				
				sOrig	= Screen('TextSize',h,fs(1));
				r1m		= Screen('TextBounds',h,'m',0,0);
				[r,r1]	= Screen('TextBounds',h,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',0,0,1);
				wm1		= r1m(3)-r1m(1);
				h1		= r1(4)-r1(2);
				b1		= abs(r1(2));
				
				Screen('TextSize',h,fs(2));
				r2m		= Screen('TextBounds',h,'m',0,0);
				[r,r2]	= Screen('TextBounds',h,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',0,0,1);
				wm2		= r2m(3)-r2m(1);
				h2		= r2(4)-r2(2);
				b2		= abs(r2(2));
				
				Screen('TextSize',h,sOrig);
				Screen('TextFont',h,fOrig);
			%relationship between font number and pixel height
				mH	= (h2-h1)./ds;
			%relationship between font number and baseline offset
				mB	= (b2-b1)./ds;
			%relationship between font number and pixel width
				mm	= (wm2-wm1)./ds;
			%store the slopes
				cFamily	= [cFamily; strFamily{kF}];
				mFamily	= [mFamily; [mm mH mB]];
		end
		
		[bExist(bCalc),kFamily(bCalc)]	= ismember(strFamily(bCalc),cFamily);
	end
	
	%map it
		pxW	= shw.parent.Window.va2px(va);
		s	= pxW./mFamily(kFamily,1);
		pxH	= mFamily(kFamily,2).*s+2;
		pxB	= mFamily(kFamily,3).*s-1;
		s	= round(s);
end
%------------------------------------------------------------------------------%


end
