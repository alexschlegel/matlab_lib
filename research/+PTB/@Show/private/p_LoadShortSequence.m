function p_LoadShortSequence(shw)
% p_LoadShortSequence
% 
% Description:	load the sequence in which Pixar Short movies should be shown
%				for the specified subject, attempting to make sure s/he doesn't
%				see the same short twice
% 
% Syntax:	p_LoadShortSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2012-12-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the number of shorts
	strDirShort	= shw.parent.File.GetDirectory('show_short');
	cPathShort	= FindFilesByExtension(strDirShort,'mkv');
	nShort		= numel(cPathShort);
	
	shw.parent.Info.Set('show',{'short','path'},cPathShort);
%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%look for an existing sequence
	sSequence	= shw.parent.File.Read('short_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
	
	if isfield(sSequence,id)
	%one was found, load it and add the new shorts
		seq		= sSequence.(id);
		nSeq	= numel(seq);
		
		seq	= [seq(seq<=nShort); (nSeq+1:nShort)'];
	else
	%generate a new one
		seq	= reshape(randomize(1:nShort),[],1);
	end
	
	shw.parent.Info.Set('show',{'short','sequence'},seq,'replace',false);
%set the next short
	shw.parent.Info.Set('show',{'short','next'},1);
