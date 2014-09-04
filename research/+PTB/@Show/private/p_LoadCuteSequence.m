function p_LoadCuteSequence(shw)
% p_LoadCuteSequence
% 
% Description:	load the sequence in which cute movies should be shown for the
%				specified subject, attempting to make sure s/he doesn't see the
%				same cute movie twice
% 
% Syntax:	p_LoadCuteSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2012-06-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the number of cute movies
	strDirCute	= shw.parent.File.GetDirectory('show_cute');
	cPathCute	= FindFilesByExtension(strDirCute,'avi');
	nCute		= numel(cPathCute);
	
	shw.parent.Info.Set('show',{'cute','path'},cPathCute);
%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%look for an existing sequence
	sSequence	= shw.parent.File.Read('cute_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
	
	if isfield(sSequence,id)
	%one was found, load it and add the new cute movies
		seq		= sSequence.(id);
		nSeq	= numel(seq);
		
		seq	= [seq(seq<=nCute); (nSeq+1:nCute)'];
	else
	%generate a new one
		seq	= reshape(randomize(1:nCute),[],1);
	end
	
	shw.parent.Info.Set('show',{'cute','sequence'},seq,'replace',false);
%set the next comic
	shw.parent.Info.Set('show',{'cute','next'},1);
