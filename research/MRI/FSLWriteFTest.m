function FSLWriteFTest(f,strPath)
% FSLWriteFTest
% 
% Description:	write an FSL-formatted f-test file
% 
% Syntax:	FSLWriteFTest(f,strPath)
% 
% In:
%	f		- an nTContrast x nFTest f-test definition
%	strPath	- the output path
% 
% Updated: 2012-03-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nTest,nWave]	= size(f);

strText	=	join([
					{['/NumWaves' 9 num2str(nWave)]
					['/NumContrasts' 9 num2str(nTest)]
					''
					'/Matrix'
					array2str(f)
					''}
				],10);

fput(strText,strPath);
