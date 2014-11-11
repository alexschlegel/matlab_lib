function Seek(mov,pos,varargin)
% PTB.Show.Movie.Seek
% 
% Description:	seek to a position in a movie
% 
% Syntax:	mov.Seek(pos,[strNameMovie]='movie',<options>)
%
% In:
%	pos				- the new position
%	[strNameMovie]	- the name of the movie
%	<options>:
%		unit:	('ms') the unit of the position.  either 'ms' for milliseconds or
%				'frame' for frame number (starting from 0)
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strNameMovie,opt]	= ParseArgs(varargin,'movie',...
						'unit'	, 'ms'	  ...
						);
opt.unit			= CheckInput(opt.unit,'unit',{'ms','frame'});

%get the movie handle
	hMovie	= mov.Get(strNameMovie);
	
	if isempty(hMovie)
		return;
	end
%seek
	switch opt.unit
		case 'ms'
			pos		= pos/1000;
			bFrames	= false;
		case 'frame'
			pos		= round(pos);
			bFrames	= true;
	end
	
	Screen('SetMovieTimeIndex',hMovie,pos,double(bFrames));
