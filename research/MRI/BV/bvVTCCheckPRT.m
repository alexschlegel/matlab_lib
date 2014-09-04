function bvVTCCheckPRT(vtc,strPath)
% bvVTCCheckPRT
% 
% Description:	make sure the VTC object has a protocol file correctly linked.
%				if not, link the protocol file implied by strPath
% 
% Syntax:	bvVTCCheckPRT(vtc,strPath)
% 
% In:
% 	vtc		- a VTC object loaded with BVQXfile
%	strPath	- either the path to a PRT file or the path to an FMR file with a
%			  PRT file linked
% 
% Updated:	2009-07-17
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
	if ~ischar(vtc.NameOfLinkedPRT)
		[dummy,dummy,strExt]	= PathSplit(strPath);
		switch lower(strExt)
			case 'fmr'
				fmr					= BVQXfile(strPath);
				vtc.NameOfLinkedPRT	= fmr.ProtocolFile;
			otherwise
				vtc.NameOfLinkedPRT	= strPath;
		end
	end
	