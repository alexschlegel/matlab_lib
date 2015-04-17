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
% Updated: 2015-04-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'units'	, []	  ...
		);
opt.units	= lower(opt.units);
bUnits		= ~isempty(opt.units);

p	= arrayfun(@GetPosition,h);

if nargout>1
	varargout	= num2cell(p);
else
	varargout{1}	= p;
end


%------------------------------------------------------------------------------%
function p = GetPosition(h) 
	strType			= lower(get(h,'type'));
	strUnitsOrig	= lower(get(h,'Units'));
	strUnits		= conditional(bUnits,opt.units,strUnitsOrig);
	
	if bUnits
		set(h,'Units',opt.units);
	end
	
	if h==0 %screen
		pE	= get(0,'ScreenSize');
		
		[p.l,p.r]	= deal(pE(1));
		[p.b,p.t]	= deal(pE(2));
		p.w			= pE(3);
		p.h			= pE(4);
	else
		%parent position
			hP	= get(h,'Parent');
			
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
			end
		%element position
			switch strType
				case 'text'
					pE	= get(h,'Extent');
				otherwise
					pE	= get(h,'Position');
			end
		
		p.l	= pE(1);
		p.t	= pP(4) - pE(4) - pE(2) + strcmp(strUnits,'pixels');
		p.w	= pE(3);
		p.h	= pE(4);
		p.b	= pE(2);
		p.r	= pP(3) - pE(3) - pE(1);
	end
	
	if bUnits
		set(h,'Units',strUnitsOrig);
	end
end
%------------------------------------------------------------------------------%

end
