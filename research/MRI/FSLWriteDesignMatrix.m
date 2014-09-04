function FSLWriteDesignMatrix(d,strPath)
% FSLWriteDesignMatrix
% 
% Description:	write an FSL-formatted design matrix file
% 
% Syntax:	FSLWriteDesignMatrix(d,strPath)
% 
% In:
% 	d		- the MxN design matrix
%	strPath	- the output path
% 
% Updated: 2011-01-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

[nPoint,nWave]	= size(d);
ppHeight		= max(d);

strText	=	join({
					['/NumWaves' 9 num2str(nWave)]
					['/NumPoints' 9 num2str(nPoint)]
					['/PPheights' 9 array2str(ppHeight)]
					''
					'/Matrix'
					array2str(d,'precision',15)
					''
				},10);

fput(strText,strPath);
