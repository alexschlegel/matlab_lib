function kID = p_GetWacomIDs
% p_GetWacomIDs
% 
% Description:	find the wacom device ids
% 
% Syntax:	kID = p_GetWacomIDs
%
% Out:
%	kID	- an array of IDs for the following:
%			stylus
%			eraser
%			touch
% 
% Updated: 2012-07-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kDevice,cDevice] = GetMouseIndices;

kStylus	= find(cellfun(@(s) ~isempty(regexp(s,'Wacom.*stylus$')),cDevice),1);
kEraser	= find(cellfun(@(s) ~isempty(regexp(s,'Wacom.*eraser$')),cDevice),1);
kTouch	= find(cellfun(@(s) ~isempty(regexp(s,'Wacom.*touch$')),cDevice),1);

if isempty(kStylus) || isempty(kEraser) || isempty(kTouch)
	error('Could not find all Wacom devices.');
end

kID	= [kDevice(kStylus); kDevice(kEraser); kDevice(kTouch)];
