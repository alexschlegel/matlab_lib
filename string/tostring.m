function str = tostring(x,varargin)
% tostring
% 
% Description:	convert a variable to a string for display
% 
% Syntax:	str = tostring(x,<options>)
% 
% In:
% 	x	- a variable
%	<options>:
%		join:	(', ') the character to use to join cell elements
%		limit:	(<none>) the maximum number of characters in the output
% 
% Out:
% 	str	- the variable as a string
% 
% Updated: 2012-12-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optDefault cOptDefault;

if isempty(optDefault)
	optDefault	= struct(...
					'join'	, ', '	, ...
					'limit'	, []	  ...
					);
	cOptDefault	= Opt2Cell(optDefault);
end

if numel(varargin)==0
	opt	= optDefault;
else
	opt	= ParseArgs(varargin,cOptDefault{:});
end

switch class(x)
	case 'cell'
		nRow	= size(x,1);
		cRow	= {};
		for kR=1:nRow
			cRow{kR}	= join(cellfun(@tostring,x(kR,:),'UniformOutput',false),opt.join);
		end
		str	= ['{' join(cRow,[char(10) ' ']) '}'];
	case 'char'
		str	= x;
	case 'logical'
		str	= join(arrayfun(@(b) conditional(b,'true','false'),x,'uni',false),' ');
	otherwise
		str	= StringTrim(evalc('disp(x)'));
end

if ~isempty(opt.limit) && numel(str)>opt.limit
	if opt.limit>=3
		str	= [str(1:opt.limit-3) '...'];
	else
		str	= str(1:opt.limit);
	end
end
