function Load(sub)
% PTB.Subject.Load
% 
% Description:	load existing subject info
% 
% Syntax:	sub.Load()
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if sub.parent.File.Exists('subject')
	ifoSubject	= sub.parent.File.Read('subject');
	
	PTBIFO.subject	= StructMerge(ifoSubject,PTBIFO.subject);
end
