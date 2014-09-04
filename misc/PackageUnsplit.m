function p = PackageUnsplit(cP)
% PackageUnsplit
% 
% Description:	unsplit a package path split with PackageSplit
% 
% Syntax:	p = PackageUnsplit(cP)
% 
% Updated: 2011-12-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p	= join(cP,'.');
