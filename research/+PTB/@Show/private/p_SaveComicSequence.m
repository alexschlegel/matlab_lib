function p_SaveComicSequence(shw)
% p_SaveComicSequence
% 
% Description:	save the comic sequence for the current subject
% 
% Syntax:	p_SaveComicSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%load the existing sequence
	sSequence	= shw.parent.File.Read('comic_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
%get the new sequence for the current subject
	seq		= shw.parent.Info.Get('show',{'comic','sequence'});
	kNext	= shw.parent.Info.Get('show',{'comic','next'});
	
	sSequence.(id)	= [seq(kNext:end); randomize(seq(1:kNext-1))];
%save the sequence file
	shw.parent.File.Write(sSequence,'comic_sequence','overwrite',true,'variable','sSequence');
