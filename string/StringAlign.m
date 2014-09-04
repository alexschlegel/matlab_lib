function str = StringAlign(c,strAlign,varargin)
% StringAlign
% 
% Description:	align a cell of strings in a char array
% 
% Syntax:	str = StringAlign(c,strAlign,<options>)
% 
% In:
% 	c			- a string or cell of strings
%	strAlign	- either 'left', 'center', or 'right'
%	<options>:
%		'length':	(<calculate>) the output length
% 
% Out:
% 	str	- a char array of the elements of c, aligned as specified
% 
% Updated:	2009-07-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'length'	, []	  ...
		);

c	= ForceCell(c);

nC	= numel(c);

%get the alignment function to use
	switch lower(strAlign)
		case 'left'
			funcAlign	= @AlignLeft;
		case 'center'
			funcAlign	= @AlignCenter;
		case 'right'
			funcAlign	= @AlignRight;
		otherwise
			error(['"' strAlign '" is not a valid alignment specifier']);
	end

%get the maximum string length
	nStr	= cellfun(@numel,c);
	if isempty(opt.length)
		nMax	= max(nStr);
	else
		nMax	= opt.length;
	end
	
%construct the output
	c	= cellfun(@(x) funcAlign(x,nMax),c,'UniformOutput',false);
	str	= char(c);

%------------------------------------------------------------------------------%
function str = AlignLeft(str,n)
	nStr	= numel(str);
	
	strPad	= repmat(' ',[1 n-nStr]);
	str		= [reshape(str,1,[]) strPad];
%------------------------------------------------------------------------------%
function str = AlignCenter(str,n)
	nStr	= numel(str);
	
	nPad	= (n-nStr)/2;
	
	strPadLeft	= repmat(' ',[1 floor(nPad)]);
	strPadRight	= repmat(' ',[1 ceil(nPad)]);
	str			= [strPadLeft reshape(str,1,[]) strPadRight];
%------------------------------------------------------------------------------%
function str = AlignRight(str,n)
	nStr	= numel(str);
	
	strPad	= repmat(' ',[1 n-nStr]);
	str		= [strPad reshape(str,1,[])];
%------------------------------------------------------------------------------%
