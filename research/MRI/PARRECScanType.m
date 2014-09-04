function strType = PARRECScanType(strPathPAR)
% PARRECScanType
% 
% Description:	determine the scan type of a PAR/REC file pair
% 
% Syntax:	strType = PARRECScanType(strPathPAR)
% 
% In:
% 	strPathPAR	- the path to the PAR file, or a PAR header
% 
% Out:
% 	strType	- one of the following:
%				'scout'			- a scout scan
%				'structural'	- a hi-res structural scan
%				'diffusion'		- a DTI scan
%				'functional'	- an EPI scan
%				'unknown'		- something else
% 
% Updated: 2013-10-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strType	= '';

if ~isstruct(strPathPAR)
	%first try without reading the header
		strFile	= PathGetFileName(strPathPAR);
		
		if strfind(strFile,'FEEPI')
			strType	= 'functional';
		elseif strfind(strFile,'DwiSE')
			strType	= 'diffusion';
		elseif strfind(strFile,'2-T1TFE')
			strType	= 'structural';
		end
		
		if ~isempty(strType)
			return;
		end
	
	%read the header
		hdr	= PARRECReadHeader(strPathPAR,'imageinfo',false);
else
	hdr	= strPathPAR;
end

if hdr.general.diffusion
	strType	= 'diffusion';
elseif hdr.general.dynamic_scan
	strType	= 'functional';
elseif CheckProtocol('scout')
	strType	= 'scout';
elseif CheckTechnique('T1TFE') && (CheckProtocol('hires') || CheckProtocol('ehalfhalf'))
	strType	= 'structural';
else
	strType	= 'unknown';
end


%------------------------------------------------------------------------------%
function b = CheckProtocol(str)
	b	= ~isempty(strfind(lower(hdr.general.protocol_name),lower(str)));
end
%------------------------------------------------------------------------------%
function b = CheckTechnique(str)
	b	= ~isempty(strfind(lower(hdr.general.technique),lower(str)));
end
%------------------------------------------------------------------------------%

end