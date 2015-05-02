function tr = GetTiming(strPathData)
% NIfTI.GetTiming
% 
% Description:	get timing info from a NIfTI functional data file
% 
% Syntax:	tr = NIfTI.GetTiming(strPathData)
% 
% In:
% 	strPathData	- the path to a NIfTI functional data set
% 
% Out:
% 	tr	- the TR duration, in seconds
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%first check for a PARREC2NIfTI .mat file
	strPathMAT	= NIfTI.PathMAT(strPathData);
	
	if ~isempty(strPathMAT)
		hdr	= load(strPathMAT,'general');
		
		tr			= round(hdr.general.repetition_time)/1000;
		
		return;
	end

%just read the NIfTI header
	hdr	= NIfTI.ReadHeader(strPathData);
	tr	= hdr.pixdim(5);
