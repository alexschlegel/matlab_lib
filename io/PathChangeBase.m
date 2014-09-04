function strPath = PathChangeBase(strPath,strPathBaseFrom,strPathBaseTo)
% PathChangeBase
% 
% Description:	change the base directory of a path
% 
% Syntax:	strPath = PathChangeBase(strPath,strPathBaseFrom,strPathBaseTo)
% 
% In:
% 	strPath			- a path
%	strPathBaseFrom	- the source base directory
%	strPathBaseTo	- the destination base directory
% 
% Out:
% 	strPath	-the path with base directory changed 
% 
% Updated: 2010-03-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPath	= PathRel2Abs(PathAbs2Rel(strPath,strPathBaseFrom),strPathBaseTo);
