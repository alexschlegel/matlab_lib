function Play(mov,varargin)
% PTB.Show.Movie.Play
% 
% Description:	start playing a movie
% 
% Syntax:	mov.Play([strNameMovie]='movie')
%
% In:
%	[strNameMovie]	- the name of the movie
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strNameMovie	= ParseArgs(varargin,'movie');

%get the movie handle
	[hMovie,strNameMovie]	= mov.Get(strNameMovie);
	
	if isempty(hMovie)
		return;
	end

%get the playback rate
	rate	= mov.parent.Info.Get(mov.type,{'rate',strNameMovie});
%start the movie
	Screen('PlayMovie', hMovie, rate);
