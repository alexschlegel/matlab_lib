function bSuccess = FreeSurferLabelWrite(sLabel,strPathLabel)
% FreeSurferLabelWrite
% 
% Description:	write to file a label struct read with FreeSurferLabelRead
% 
% Syntax:	bSuccess = FreeSurferLabelWrite(sLabel,strPathLabel)
% 
% In:
% 	sLabel			- a label struct read with FreeSurferLabelRead
%	strPathLabel	- the output file name
% 
% Out:
% 	bSuccess	- true if the label file was successfully written
% 
% Updated: 2011-02-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

strLabel	=	[...
					sLabel.hdr									10 ...
					num2str(numel(sLabel.k))					10 ...
					array2str([sLabel.k sLabel.v sLabel.stat])	10 ...
				];

bSuccess	= fput(strLabel,strPathLabel);
