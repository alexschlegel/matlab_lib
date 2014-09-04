function Clear
% PTB.Clear
% 
% Description:	clear everything to prepare for a fresh call to PTB.Experiment
% 
% Syntax:	PTB.Clear
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
delete(timerfind);
evalin('base','clear classes');
