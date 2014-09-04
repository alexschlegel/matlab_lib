function str = StringFill(x,varargin)
% StringFill
% 
% Description:	fill the edges of a string with characters until it's a
%				specified length
% 
% Syntax:	str = StringFill(x,[n]=<maximum length in x>,[chr]='0',[fillType]='left')
%
% In:
%	x			- a number, string, or cell of numbers and strings
%	[n]			- the desired length
%	[chr]		- the fill character
%	[fillType]	- the fill method.  either 'left', 'center', or 'right'.
%				  'left' puts the fill characters on the left, 'center' centers
%				  the text, ...
% 
% Out:
%	str	- a character array of the elements of x filled to the desired length
%
% Updated:	2009-10-20
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%convert to strings and find the maximum length
	x		= ForceCell(x);
	nX		= numel(x);
	nMax	= 0;
	nXTotal	= 0;
	for k=1:nX
		if ~ischar(x{k})
			if isnumeric(x{k})
				x{k}	= num2str(x{k});
			else
				x{k}	= char(x{k});
			end
		end
		
		nMax	= max(nMax,size(x{k},2));
		nXTotal	= nXTotal + size(x{k},1);
	end

%optional arguments
	[n,chr,fillType]	= ParseArgs(varargin,0,'0','left');
	
	n	= max(n,nMax);
	
	switch lower(fillType)
		case 'left'
			funcPad	= @PadLeft;
		case 'center'
			funcPad	= @PadCenter;
		case 'right'
			funcPad	= @PadRight;
		otherwise
			error([fillType ' is not a valid fill type.']);
	end

%construct the output
	str	= char(zeros(nX,n));
	
	kCol	= 1;
	for k=1:nX
		nCur	= max(size(x{k},1),1);
		nStr	= size(x{k},2);
		
		str(kCol+(0:nCur-1),:)	= funcPad(x{k},n-nStr,chr);
		
		kCol	= kCol + nCur;
	end
	
%------------------------------------------------------------------------------%
function str = PadLeft(str,n,chr)
	str	= [repmat(chr,[1 n]) str];
%------------------------------------------------------------------------------%
function str = PadCenter(str,n,chr)
	n2	= n/2;
	str	= [repmat(chr,[1 floor(n2)]) str repmat(chr,[1 ceil(n2)])];
%------------------------------------------------------------------------------%
function str = PadRight(str,n,chr)
	str	= [str repmat(chr,[1 n])];
%------------------------------------------------------------------------------%
