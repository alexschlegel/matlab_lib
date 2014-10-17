function FSLWriteTContrast(ct,strPath,varargin)
% FSLWriteTContrast
% 
% Description:	write an FSL-formatted t-contrast file
% 
% Syntax:	FSLWriteTContrast(ct,strPath,<options>)
% 
% In:
% 	ct		- an MxN matrix defining M t-contrasts for a design matrix with N
%			  explanatory variables
%	strPath	- the output path
%	<options>:
%		name:	(<auto>) an M-length cell of contrast names
% 
% Updated: 2011-01-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'name'	, []	  ...
		);

[nContrast,nWave]	= size(ct);
%ppHeights			= max(d);???***

if isempty(opt.name)
	opt.name	= arrayfun(@(x) ['contrast' num2str(x)],1:nContrast,'UniformOutput',false);
end

strText	=	join([
					arrayfun(@(x) ['/ContrastName' num2str(x) 9 '"' opt.name{x} '"'],reshape(1:nContrast,[],1),'UniformOutput',false)
					{['/NumWaves' 9 num2str(nWave)]
					['/NumContrasts' 9 num2str(nContrast)]
					['/PPheights' 9 join(repmat({'???'},[nWave 1]),9)]
					['/RequiredEffect' 9 join(repmat({'???'},[nWave 1]),9)]
					''
					'/Matrix'
					array2str(ct)
					''}
				],10);

fput(strText,strPath);
