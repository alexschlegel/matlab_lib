function bAbort	= p_AutoSave(ifo)
% p_AutoSave
% 
% Description:	autosave the info struct
% 
% Syntax:	bAbort	= p_AutoSave(ifo)
%
% Updated: 2011-12-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t1		= PTB.Now;
bAbort	= ~ifo.Save;
t2		= PTB.Now;

if ~bAbort
	ifo.AddLog(['autosave (' num2str(round(t2-t1)) 'ms)'],t1);
end
