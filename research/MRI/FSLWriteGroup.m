function FSLWriteGroup(g,strPath)
% FSLWriteGroup
% 
% Description:	write an FSL-formatted group file
% 
% Syntax:	FSLWriteGroup(g,strPath)
% 
% In:
% 	g		- an N-length array specifying the group membership of each point in
%			  the corresponding design matrix
%	strPath	- the output path
% 
% Updated: 2011-01-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

nWave	= 1;
nPoint	= numel(g);

strText	=	join([
					{['/NumWaves' 9 num2str(nWave)]
					['/NumPoints' 9 num2str(nPoint)]
					''
					'/Matrix'
					array2str(reshape(g,[],1))
					''}
				],10);

fput(strText,strPath);
