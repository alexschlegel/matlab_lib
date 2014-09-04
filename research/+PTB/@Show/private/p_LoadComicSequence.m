function p_LoadComicSequence(shw)
% p_LoadComicSequence
% 
% Description:	load the sequence in which comics should be shown for the
%				specified subject, attempting to make sure s/he doesn't see the
%				same comic twice
% 
% Syntax:	p_LoadComicSequence(shw)
% 
% In:
% 	shw	- the Show object
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the number of comics
	strDirComic	= shw.parent.File.GetDirectory('show_comic');
	cPathComic	= FindFilesByExtension(strDirComic,{'jpg','png'});
	nComic		= numel(cPathComic);
	
	shw.parent.Info.Set('show',{'comic','path'},cPathComic);
%get the subject id
	id	= str2fieldname(shw.parent.Info.Get('subject','init'));
%look for an existing sequence
	sSequence	= shw.parent.File.Read('comic_sequence');
	
	if isempty(sSequence)
		sSequence	= struct;
	end
	
	if isfield(sSequence,id)
	%one was found, load it and add the new comics
		seq		= sSequence.(id);
		nSeq	= numel(seq);
		
		seq	= [seq(seq<=nComic); (nSeq+1:nComic)'];
	else
	%generate a new one
		seq	= reshape(randomize(1:nComic),[],1);
	end
	
	shw.parent.Info.Set('show',{'comic','sequence'},seq,'replace',false);
%set the next comic
	shw.parent.Info.Set('show',{'comic','next'},1);
