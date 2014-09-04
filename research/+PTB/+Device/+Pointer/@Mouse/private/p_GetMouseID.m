function kID = p_GetMouseID
% p_GetMouseID
% 
% Description:	find the mouse device id
% 
% Syntax:	kMouse = p_GetMouseID
% 
% Updated: 2012-07-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kDevice,cDevice] = GetMouseIndices;

kMouse	= find(ismember(cDevice,{'Virtual core pointer','PS/2 Mouse','Mouse'}),1);

if isempty(kMouse)
	error('Could not find mouse device.');
end

kID	= kDevice(kMouse);
