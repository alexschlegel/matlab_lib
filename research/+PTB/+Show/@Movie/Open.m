function hMovie = Open(mov,strPathMovie,varargin)
% PTB.Show.Movie.Open
% 
% Description:	open a movie file
% 
% Syntax:	hMovie = mov.Open(strPathMovie,<options>)
%
% In:
%	strPathMovie	- the path to the movie
%	<options>:
%		name:		('movie') the name of the movie, for referring to later
%		rate:		(<actual>) the movie playback rate, in Hz
%		preload:	(1000) number of milliseconds of data to preload
%		window:		('main') the window for playback
% 
% Out:
%	hMovie	- the handle to the movie
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'name'		, 'movie'	, ...
		'rate'		, []		, ...
		'preload'	, 1000		, ...
		'window'	, 'main'	  ...
		);

%make sure we have the necessary privileges
	if ~isroot
		error('PTB.Show.Movie needs root privileges.');
	end

%close the movie if it already exists
	mov.Close(opt.name);
%open the movie
	hWin	= mov.parent.Window.Get(opt.window);
	
	[hMovie,dur,fps,w,h]	= Screen('OpenMovie',hWin,strPathMovie,0,opt.preload/1000);
	
	mov.parent.Info.Set(mov.type,{'h',opt.name},hMovie);
	mov.parent.Info.Set(mov.type,{'window',opt.name},hWin);
	mov.parent.Info.Set(mov.type,{'path',opt.name},strPathMovie);
%save some info
	%rate
		opt.rate	= unless(opt.rate,fps);
		
		mov.parent.Info.Set(mov.type,{'rate',opt.name},opt.rate/fps);
