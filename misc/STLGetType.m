function [strType,strSTL] = STLGetType(strPathSTL)
% STLGetType
% 
% Description:	get the type of an STL file, either 'binary' or 'ascii'
% 
% Syntax:	[strType,strSTL] = STLGetType(strPathSTL)
% 
% Updated:	2009-02-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%open the file
	fid	= fopen(strPathSTL,'r');

%read the contents into a char array
	strSTL	= reshape(char(fread(fid,inf,'uchar')),1,[]);

%close the file
	fclose(fid);
	
%if we have certain strings in the file, consider it ascii
	strType	= 'ascii';
	
	cSearch	= {'facet','normal','outer loop','vertex','endloop','endfacet'};
	nSearch	= numel(cSearch);
	for kS=1:nSearch
		if isempty(strfind(strSTL,cSearch{kS}))
			strType	= 'binary';
			break;
		end
	end
	