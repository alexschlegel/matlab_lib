function bSuccess = fput(x,strPath,varargin)
% fput
% 
% Description:	write x to file strPath
% 
% Syntax:	bSuccess = fput(x,strPath,<options>)
% 
% In:
%	x		- the array to write
% 	strPath	- the path to the file
%	<options>:
%		precision:	(class(x)) the data type to write
%		append:		(false) true to append the string, false to overwrite
% 
% Out:
%	bSuccess	- true if the file was successfully written
% 
% Updated:	2013-02-04
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optDefault cOptDefault;

if isempty(optDefault)
	optDefault		= struct(...
						'precision'	, []	, ...
						'append'	, false	  ...
						);
	cOptDefault		= Opt2Cell(optDefault);
end

if numel(varargin)>0
	opt	= ParseArgs(varargin,cOptDefault{:});
else
	opt		= optDefault;
end

if isempty(opt.precision)
	opt.precision	= class(x);
end

p	= conditional(opt.append,'a','w');

fid			= fopen(strPath,p);
bSuccess	= ~isequal(fid,-1);

if bSuccess
	fwrite(fid,x,opt.precision);
	fclose(fid);
end
