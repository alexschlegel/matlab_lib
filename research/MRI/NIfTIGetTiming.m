function [tr,s] = NIfTIGetTiming(strPathData)
% NIfTIGetTiming
% 
% Description:	get timing info from a NIfTI functional data file
% 
% Syntax:	[tr,s] = NIfTIGetTiming(strPathData)
% 
% In:
% 	strPathData	- the path to a NIfTI functional data set
% 
% Out:
% 	tr		- the TR duration, in seconds
%	s		- a struct of other potentially useful information:
%				nvol:	number of volumes in the data set
%				nslice:	number of slices in each volume
% 
% Updated: 2014-11-13
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

s	= struct;

%first check for a PARREC2NIfTI .mat file
	strPathMAT	= NIfTIPathMAT(strPathData);
	
	if ~isempty(strPathMAT)
		hdr	= load(strPathMAT,'general');
		
		tr			= round(hdr.general.repetition_time)/1000;
		s.nvol		= hdr.general.max_number_of_dynamics;
		s.nslice	= hdr.general.max_number_of_slices;
		
		return
	end
%now try FSLReadHeader
	hdr	= FSLReadHeader(strPathData);
	
	tr			= hdr.pixdim4;
	s.nvol		= hdr.dim4;
	s.nslice	= hdr.dim3;
