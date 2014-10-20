function strPath = svgstruct2path(sPath)
% svgstruct2path
% 
% Description:	convert an svg struct back to a path
% 
% Syntax:	strPath = svgstruct2path(sPath)
% 
% Updated: 2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cCommand	= {sPath.command};
cParam		= {sPath.param};

cOp	= cellfun(@(c,p) sprintf('%s%s',c,join(p,' ')),cCommand,cParam,'uni',false);

strPath	= join(cOp,' ');
