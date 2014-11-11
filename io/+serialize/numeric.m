function str = numeric(x,varargin)
% serialize.numeric
% 
% Description:	serialize a numeric array
% 
% Syntax:	str = numeric(x,<options>)
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'numeric_first'	, true	  ...
		);

sz	= size(x);
nd	= numel(sz);

if isscalar(x)
	str	= serialize.scalar(x,varargin{:});
elseif nd==2
	cRow	= cell(sz(1),1);
	for kR=1:sz(1)
		cRow{kR}	= join(arrayfun(@(x) serialize.scalar(x,varargin{:}),x(kR,:),'uni',false),',');
	end
	
	str	= ['[' join(cRow,';') ']'];
else
	cX		= cell(sz(end),1);
	cRefPre	= repmat({':'},[nd-1 1]);
	
	for k=1:sz(end)
		cX{k}	= x(cRefPre{:},k);
	end
	
	str	= serialize.call('cat',[nd;cX],varargin{:},'numeric_first',false);
end


if opt.numeric_first
	cls	= class(x);
	switch cls
		case 'double'
		otherwise
			str	= [cls '(' str ')'];
	end
end
