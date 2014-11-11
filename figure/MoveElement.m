function varargout = MoveElement(h,varargin)
% MoveElement
% 
% Description:	move an element in a figure
% 
% Syntax:	p = MoveElement(h,<options>) OR
%			[p1,...,pK] = MoveElement(h,<options>)
% 
% In:
% 	h	- an array of element handles
%	<options>:
%		l:			(<keep>) the new left position
%		t:			(<keep>) the new top position
%		w:			(<keep>) the new width
%		h:			(<keep>) the new height
%		b:			(<keep>) the new bottom position
%		r:			(<keep>) the new right position
%		stretch:	(false) true to keep the opposite side of the element
%					anchored (e.g. setting 'r' keeps the left side of the
%					element fixed)
%		center:		(false) true to center the element in its parent
% 
% Out:
%	p	- an array of the elements' new positions (see GetElementPosition)
%	pK	- the new position of the Kth element
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'l'			, []	, ...
		't'			, []	, ...
		'w'			, []	, ...
		'h'			, []	, ...
		'b'			, []	, ...
		'r'			, []	, ...
		'stretch'	, false	, ...
		'center'	, false	  ...
		);
		
nH	= numel(h);

for kH=1:nH
	strType		= lower(get(h(kH),'type'));
	strUnits	= lower(get(h(kH),'Units'));
	
	%normalized units?
		bNormalized	= isequal(get(h(kH),'Units'),'normalized');
		bPixels		= isequal(get(h(kH),'Units'),'pixels');
	%parent position
		hP	= get(h(kH),'Parent');
		pP	= GetElementPosition(hP);
		switch strUnits
			case 'normalized'
				pP.w	= 1;
				pP.h	= 1;
			case 'data'
				pP.w	= diff(get(hP,'XLim'));
				pP.h	= diff(get(hP,'YLim'));
			otherwise
		end
	%element position
		pE	= GetElementPosition(h(kH));
	%get the new position
		if opt.center
			MoveElement(h(kH),'l',(pP.w-pE.w)/2,'t',(pP.h-pE.h)/2);
		else
			if ~isempty(opt.w)
				pE.w	= opt.w;
			end
			if ~isempty(opt.h)
				pE.h	= opt.h;
			end
			if ~isempty(opt.l)
				if opt.stretch
					pE.w	= pE.w + pE.l-opt.l;
				end
				pE.l	= opt.l;
			end
			if ~isempty(opt.t)
				if opt.stretch
					pE.h	= pE.h + pE.t-opt.t-bPixels;
				else
					pE.b	= pP.h-pE.h-opt.t+bPixels;
				end
			end
			if ~isempty(opt.b)
				if opt.stretch
					pE.h	= pE.h + pE.b-opt.b;
				end
				pE.b	= opt.b;
			end
			if ~isempty(opt.r)
				if opt.stretch
					pE.w	= pE.w + pE.r-opt.r;
				else
					pE.l	= pP.w-pE.w-opt.r;
					line([pE.l;pE.l],get(gca,'YLim')');
				end
			end
			
			switch strType
				case 'text'
					set(h(kH),'Position',[pE.l pE.b]);
				otherwise
					set(h(kH),'Position',[pE.l pE.b pE.w pE.h]);
			end
		end
end

[varargout{1:nargout}]	= GetElementPosition(h);
