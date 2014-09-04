function sLabel = FreeSurferLabelRead(strPathLabel)
% FreeSurferLabelRead
% 
% Description:	read a FreeSurfer label file into a struct
% 
% Syntax:	sLabel = FreeSurferLabelRead(strPathLabel)
% 
% In:
% 	strPathLabel	- the path to the label file
% 
% Out:
% 	sLabel	- the following struct:
%				.hdr:	the 
%				.k:		an Nx1 array of vertex indicdes
%				.v:		an Nx3 array of (x,y,z) vertex coordinates
%				.stat:	an Nx1 array of vertex stat values
% 
% Updated: 2011-02-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sLabel	= [];

%read in the file
	try
		strLabel	= fget(strPathLabel);
	catch me
		return;
	end
%split the file
	sRE	= regexp(strLabel,'(?<hdr>^[^\n\r]*)[\n\r]+(?<nvertex>[^\n\r]*)[\n\r]*(?<data>.*)','names');
%convert the data table to an array
	d	= str2array(sRE.data);
%extract the info
	sLabel.hdr	= sRE.hdr;
	sLabel.k	= d(:,1);
	sLabel.v	= d(:,2:4);
	sLabel.stat	= d(:,5);
