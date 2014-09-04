function Close(mov,varargin)
% PTB.Show.Movie.Close
% 
% Description:	close a movie file
% 
% Syntax:	mov.Close([strNameMovie]='movie')
%
% In:
%	[strNameMovie]	- the name of the movie
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

strNameMovie	= ParseArgs(varargin,'movie');

%get the movie handle
	[hMovie,strNameMovie]	= mov.Get(strNameMovie);
	
	if isempty(hMovie)
		return;
	end

try
	%stop the movie
		mov.Stop(hMovie);
	%close it
		Screen('CloseMovie',hMovie);
	%remove its info
		PTBIFO.(mov.type).h			= rmfield(PTBIFO.(mov.type).h,strNameMovie);
		PTBIFO.(mov.type).path		= rmfield(PTBIFO.(mov.type).path,strNameMovie);
		PTBIFO.(mov.type).rate		= rmfield(PTBIFO.(mov.type).rate,strNameMovie);
		PTBIFO.(mov.type).window	= rmfield(PTBIFO.(mov.type).window,strNameMovie);
catch me

end
