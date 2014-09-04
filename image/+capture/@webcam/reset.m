function reset(wc,varargin)
% capture.webcam.reset
% 
% Description:	stop and reset the webcam acquisition 
% 
% Syntax:	wc.reset
% 
% Updated: 2013-07-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
wc.p_VIStop;
wc.p_VIStart;

reset@capture.base(wc);
