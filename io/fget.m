function x = fget(strPath,varargin)
% fget
% 
% Description:	read the contents of a file
% 
% Syntax:	x = fget(strPath,<options>)
% 
% In:
% 	strPath	- the path to the file
%	<options>:
%		precision:	('char') the data type to read
%		error:		(true) true to error if the file doesn't exist
%
% 
% Out:
% 	str	- the contents of the file
% 
% Updated:	2013-02-04
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optDefault cOptDefault;

if isempty(optDefault)
	optDefault		= struct(...
						'precision'	, 'char'	, ...
						'error'		, true		  ...
						);
	cOptDefault		= Opt2Cell(optDefault);
end

if numel(varargin)>0
	opt	= ParseArgs(varargin,cOptDefault{:});
else
	opt		= optDefault;
end

if opt.error || FileExists(strPath)
	fid		= fopen(strPath,'r');
	x		= cast(fread(fid,opt.precision),opt.precision)';
	fclose(fid);
else
	x	= cast('',opt.precision);
end