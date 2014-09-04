function varargout = GetElementPosition(h,varargin)
% GetElementPosition
% 
% Description:	get the position of a figure element
% 
% Syntax:	p = GetElementPosition(h,<options>) OR
%			[p1,...,pN] = GetElementPosition(h,<options>)
% 
% In:
% 	h	- an array of handles to elements
%	<options>:
%		units:	(<default>) the unit of the output struct
% 
% Out:
% 	p	- an array of the following struct:
%			l:	the element's left position
%			t:	the element's top position
%			w:	the element's width
%			h:	the element's height
%			b:	the element's bottom position
%			r:	the element's right position
%	pK	- the struct for the Kth element
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'units'	, []	  ...
		);
opt.units	= lower(opt.units);
bUnits		= ~isempty(opt.units);

nH	= numel(h);

p	= repmat(struct,[nH 1]);
for kH=1:nH
	strType			= lower(get(h(kH),'type'));
	strUnitsOrig	= lower(get(h(kH),'Units'));
	strUnits		= conditional(bUnits,opt.units,strUnitsOrig);
	
	if bUnits
		set(h(kH),'Units',opt.units);
	end
	
	if isempty(h(kH)) || h(kH)==0 %screen
		pE	= get(0,'ScreenSize');
		
		[p(kH).l,p(kH).r]	= deal(pE(1));
		[p(kH).b,p(kH).t]	= deal(pE(2));
		p(kH).w				= pE(3);
		p(kH).h				= pE(4);
	else
		%parent position
			hP	= get(h(kH),'Parent');
			
			if isempty(hP) || hP==0
				pP	= get(0,'ScreenSize');
			else
				pP	= get(hP,'Position');
			end
			
			switch strUnits
				case 'normalized'
					pP(3:4)	= 1;
				case 'data'
					pP(3)	= diff(get(hP,'XLim'));
					pP(4)	= diff(get(hP,'YLim'));
				otherwise
			end
		%element position
			switch strType
				case 'text'
					pE	= get(h(kH),'Extent');
				otherwise
					pE	= get(h(kH),'Position');
			end
		
		p(kH).l	= pE(1);
		p(kH).t	= pP(4) - pE(4) - pE(2) + isequal(strUnits,'pixels');
		p(kH).w	= pE(3);
		p(kH).h	= pE(4);
		p(kH).b	= pE(2);
		p(kH).r	= pP(3) - pE(3) - pE(1);
	end
	
	if bUnits
		set(h(kH),'Units',strUnitsOrig);
	end
end

if nargout>1
	varargout	= arrayfun(@(x) x,p,'UniformOutput',false);
else
	varargout{1}	= p;
end
