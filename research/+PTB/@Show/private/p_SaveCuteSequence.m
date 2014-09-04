function p_SaveCuteSequence(shw)
% p_SaveCuteSequence
% 
% Description:	save the cute sequence for the current subject
% 
% Syntax:	p_SaveCuteSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2012-06-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%load the existing sequence
	sSequence	= shw.parent.File.Read('cute_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
%get the new sequence for the current subject
	seq		= shw.parent.Info.Get('show',{'cute','sequence'});
	kNext	= shw.parent.Info.Get('show',{'cute','next'});
	
	sSequence.(id)	= [seq(kNext:end); randomize(seq(1:kNext-1))];
%save the sequence file
	shw.parent.File.Write(sSequence,'cute_sequence','overwrite',true,'variable','sSequence');
