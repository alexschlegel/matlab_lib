function b = FSLCompareDesign(strDirDesign,d,t,varargin)
% FSLCompareDesign
% 
% Description:	check to see if an analysis directory represents the specified
%				analysis
% 
% Syntax:	b = FSLCompareDesign(strDirDesign,d,t,[f]=<none>,<options>) 
% 
% In:
% 	strDirDesign	- the path to a directory containing FSL design files
%	d				- the nData x nEV design matrix
%	t				- the nEV x nTContrast t-contrast definition
%	[f]				- the nFTest x nTContrast f-test definition
%	<options>:
%		name:	('design') the pre-extension name of the design files
% 
% Out:
% 	b	- true if the design in the specified directory is the same as that
%		  specified by d, t, and f
% 
% Updated: 2012-03-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[f,opt]	= ParseArgs(varargin,[],...
			'name'	, 'design'	  ...
			);

b	= false;

%read the design from the design directory
	strPathD	= PathUnsplit(strDirDesign,opt.name,'mat');
	strPathT	= PathUnsplit(strDirDesign,opt.name,'con');
	strPathF	= PathUnsplit(strDirDesign,opt.name,'fts');

if ~FileExists(strPathD) || ~FileExists(strPathT) || (~isempty(f) && ~FileExists(strPathF))
%design files don't exist
	return;
end

dD	= FSLReadDesignMatrix(strPathD);
tD	= FSLReadTContrast(strPathT);

if ~isempty(f)
	fD	= FSLReadFTest(strPathF);
else
	fD	= [];
end

b	= TestArray(d,dD) && TestArray(t,tD) && (isempty(f) || TestArray(f,fD));

%------------------------------------------------------------------------------%
function b = TestArray(x,y)
	b	= false;
	
	if size(x)==size(y)
		b	= all(reshape( x==y | (x+y)./(2*(x-y)) <= 0.01 ,[],1));
	end
end
%------------------------------------------------------------------------------%

end
