function strDir = GetDirMATLAB()
% GetDirMATLAB
% 
% Description:	get the root MATLAB program directory
% 
% Syntax:	strDir = GetDirMATLAB()
% 
% Updated:	2009-03-10
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%where is which?
	strPathWhich	= which('which');
	
	re	= 'built-in \((?<path>.+)\)';
	res	= regexp(strPathWhich,re,'names');
	if ~isempty(res)
		strPathWhich	= res.path;
	end
	
%get the directory path up until the parent of 'toolbox'
	cDir		= DirSplit(strPathWhich);
	kToolbox	= FindCell(cDir,'toolbox');
	kToolbox	= kToolbox(1);
	
	strDir	= DirUnsplit(cDir(1:kToolbox-1));