function [tr,nVol] = NIfTIGetTiming(strPathData)
% NIfTIGetTiming
% 
% Description:	get timing info from a NIfTI functional data file
% 
% Syntax:	[tr,nVol] = NIfTIGetTiming(strPathData)
% 
% In:
% 	strPathData	- the path to a NIfTI functional data set
% 
% Out:
% 	tr		- the TR duration, in seconds
%	nVol	- the number of volumes in the data set
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%first check for a PARREC2NIfTI .mat file
	strPathMAT	= NIfTIPathMAT(strPathData);
	
	if ~isempty(strPathMAT)
		hdr	= load(strPathMAT,'general');
		
		tr		= round(hdr.general.repetition_time)/1000;
		nVol	= hdr.general.max_number_of_dynamics;
		
		return
	end
%now try FSLReadHeader
	hdr	= FSLReadHeader(strPathData);
	
	tr		= hdr.pixdim4;
	nVol	= hdr.dim4;
