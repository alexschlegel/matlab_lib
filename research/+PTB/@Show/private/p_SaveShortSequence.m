function p_SaveShortSequence(shw)
% p_SaveShortSequence
% 
% Description:	save the Pixar Short sequence for the current subject
% 
% Syntax:	p_SaveShortSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2012-12-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%load the existing sequence
	sSequence	= shw.parent.File.Read('short_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
%get the new sequence for the current subject
	seq		= shw.parent.Info.Get('show',{'short','sequence'});
	kNext	= shw.parent.Info.Get('show',{'short','next'});
	
	sSequence.(id)	= [seq(kNext:end); randomize(seq(1:kNext-1))];
%save the sequence file
	shw.parent.File.Write(sSequence,'short_sequence','overwrite',true,'variable','sSequence');
