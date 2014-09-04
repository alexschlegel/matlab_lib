function Save(sub)
% PTB.Subject.Save
% 
% Description:	save subject info to file
% 
% Syntax:	sub.Save()
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if sub.parent.File.Exists('subject')
	ifoSubject	= StructMerge(sub.parent.File.Read('subject'),PTBIFO.subject);
else
	ifoSubject	= PTBIFO.subject;
end

ifoSubject	= rmfield(ifoSubject,{'code','load'});

sub.parent.File.Write(ifoSubject,'subject','overwrite',true,'variable','ifoSubject');
