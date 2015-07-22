function pauseUntil(t)
% pauseUntil
%
% Description:	pause until the specified nowms style time
%
% Syntax:	pauseUntil(t)
%
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent fWait;

if isempty(fWait)
	fWait	= conditional(exist('WaitSecs')==3,@WaitSecs,@pause);
end

fWait((t - nowms)/1000);
