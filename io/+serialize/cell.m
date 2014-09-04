function str = cell(x,varargin)
% serialize.cell
% 
% Description:	serialize a cell array
% 
% Syntax:	str = cell(x,<options>)
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sz	= size(x);
nd	= numel(sz);

if nd==2
	cRow	= cell(sz(1),1);
	for kR=1:sz(1)
		cRow{kR}	= join(cellfun(@(x) serialize.to(x,varargin{:}),x(kR,:),'uni',false),',');
	end
	
	str	= ['{' join(cRow,';') '}'];
else
	cX		= cell(sz(end),1);
	cRefPre	= repmat({':'},[nd-1 1]);
	
	for k=1:sz(end)
		cX{k}	= x(cRefPre{:},k);
	end
	
	str	= serialize.call('cat',[nd;cX],varargin{:});
end
