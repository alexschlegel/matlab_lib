function init(cap)
% capture.base.reset
% 
% Description:	initialize some stuff 
% 
% Syntax:	cap.init
% 
% Updated: 2013-07-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cap.result.status		= 'initialized';
cap.result.interval		= [];
cap.result.remaining	= [];
cap.result.next			= [];
cap.result.t			= [];
cap.result.im			= zeros(0,0,0,0,'uint8');
