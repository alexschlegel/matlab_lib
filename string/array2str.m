function str = array2str(x,varargin)
% array2str
% 
% Description:	convert a 1- or 2-D numeric array to a string representation
% 
% Syntax:	str = array2str(x,<options>)
% 
% In:
% 	x	- an MxN numeric array
%	<options>:
%		precision:	(<auto>) precision, see N argument of num2str
%		format:		('tab') the output format.  one of the following:
%						'tab':	tab-delimited
%						'csv':	comma-separated variable format
%						'odf':	OpenOffice formula format
% 
% Out:
% 	str	- a string representing x
% 
% Updated: 2012-03-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'precision'	, []	, ...
		'format'	, 'tab'	  ...
		);
opt.format	= CheckInput(opt.format,'format',{'tab','csv','odf'});

if isempty(x)
	str	= '';
	return;
end

[nR,nC]	= size(x);

%convert to strings
	if ~isempty(opt.precision)
		x	= cellfun(@(x) num2str(x,opt.precision),num2cell(x),'UniformOutput',false);
	else
		x	= cellfun(@(x) num2str(x),num2cell(x),'UniformOutput',false);
	end
%separate each row
	x	= mat2cell(x,ones(nR,1),nC);

switch opt.format
	case 'tab'
		strPre	= '';
		strC	= 9;
		strR	= 10;
		strPost	= '';
	case 'csv'
		strPre	= '"';
		strC	= '","';
		strR	= ['"' 10];
		strPost	= '"';
	case 'odf'
		strPre	= 'left [ matrix{';
		strC	= ' # ';
		strR	= ' ## ';
		strPost	= '} right ]';
end

str	= cellfun(@(x) join(x,strC),x,'UniformOutput',false);
str	= [strPre join(str,strR) strPost];
