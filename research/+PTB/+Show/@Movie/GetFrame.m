function hTexture = GetFrame(mov,varargin)
% PTB.Show.Movie.GetFrame
% 
% Description:	get the next movie frame
% 
% Syntax:	hTexture = mov.GetFrame(<options>)
%
% In:
%	<options>:
%		name:	('movie') the name of the movie
%		wait:	(true) wait to return the frame until the proper time according
%				to the playback rate
%
% Out:
%	hTexture	- a handle to a texture containing the frame, or -1 if the movie
%				  is finished
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'name'	, 'movie'	, ...
						'wait'	, true		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<2
		opt	= optDefault;
	else
		opt	= ParseArgs(varargin,cOptDefault{:});
	end

bPlaying	= false;

%get the movie handle
	[hMovie,strNameMovie]	= mov.Get(opt.name);
	
	if isempty(hMovie)
		return;
	end
%get the parent window
	hWindow	= PTBIFO.(mov.type).window.(strNameMovie);
%get the texture
	hTexture	= Screen('GetMovieImage', hWindow, hMovie, double(opt.wait));
