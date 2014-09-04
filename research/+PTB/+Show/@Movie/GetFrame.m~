function Stop(mov,varargin)
% PTB.Show.Movie.Stop
% 
% Description:	stop a movie
% 
% Syntax:	mov.Stop([strNameMovie]='movie')
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
	hMovie	= mov.Get(strNameMovie);
	
	if isempty(hMovie)
		return;
	end

try
	%stop the movie
		Screen('PlayMovie', hMovie, 0);
catch me

end
