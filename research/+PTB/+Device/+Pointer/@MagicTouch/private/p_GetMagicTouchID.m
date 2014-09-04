function kID = p_GetMagicTouchID
% p_GetMagicTouchID
% 
% Description:	find the magictouch device id
% 
% Syntax:	kID = p_GetMagicTouchID
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kDevice,cDevice] = GetMouseIndices;

kID	= find(ismember(cDevice,'Keytec Magic Touch USB'));

if isempty(kID)
	error('Could not find MagicTouch device.');
end

kID	= kDevice(kID);
