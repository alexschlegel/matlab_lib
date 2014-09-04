function d = FSLReadDesignMatrix(strPath)
% FSLReadDesignMatrix
% 
% Description:	read an FSL-formatted design matrix file
% 
% Syntax:	d = FSLReadDesignMatrix(strPath)
% 
% Updated: 2011-11-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strFile	= fget(strPath);
s		= regexp(strFile,'/Matrix[\r\n]+(?<mat>.+)$','names');
d		= str2array(s.mat);
