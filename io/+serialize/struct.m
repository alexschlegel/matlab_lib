function str = struct(x,varargin)
% serialize.struct
% 
% Description:	serialize a struct array
% 
% Syntax:	str = serialize.struct(x,<options>)
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sz	= size(x);
nd	= numel(sz);

if isscalar(x)
	cField	= fieldnames(x);
	cValue	= struct2cell(x);
	nField	= numel(cField);
	
	cArg			= cell(2*nField,1);
	cArg(1:2:end)	= cField;
	cArg(2:2:end)	= cellfun(@(x) {x},cValue,'uni',false);
	
	str	= serialize.call('struct',cArg,varargin{:});
elseif nd==2
	cRow	= cell(sz(1),1);
	for kR=1:sz(1)
		cRow{kR}	= join(arrayfun(@(x) serialize.struct(x,varargin{:}),x(kR,:),'uni',false),',');
	end
	
	str	= ['[' join(cRow,';') ']'];
else
	cX		= cell(sz(end),1);
	cRefPre	= repmat({':'},[nd-1 1]);
	
	for k=1:sz(end)
		cX{k}	= x(cRefPre{:},k);
	end
	
	str	= serialize.call('cat',[nd;cX],varargin{:});
end
