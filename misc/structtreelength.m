function sLength = structtreelength(s)
% structtreelength
% 
% Description:	determine the minimum path length of each point in a structtree
% 
% Syntax:	sLength = structtreelength(s)
% 
% Updated: 2015-04-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isstruct(s)
	sLength.tree	= structfun2(@structtreelength,s);
	sLength.length	= 1 + unless(min(structfun(@(x) x.length,sLength.tree)),0);
else
	sLength	= struct('length',0,'tree',[]);
end
