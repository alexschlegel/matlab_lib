function [hMovie,varargout] = Get(mov,strNameMovie)
% PTB.Show.Movie.Get
% 
% Description:	get the handle to a movie
% 
% Syntax:	[hMovie,strNameMovie]	= mov.Get(strNameMovie);
% 
% In:
%	strNameMovie	- the name of the movie
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if ischar(strNameMovie)
	try
		hMovie	= PTBIFO.(mov.type).h.(strNameMovie);
	catch me
		hMovie	= [];
	end
	
	varargout{1}	= strNameMovie;
else
	hMovie	= strNameMovie;
	
	if nargout>1
	%get the movie name
		hMovies	= mov.parent.Info.Get(mov.type,'h');
		cField	= fieldnames(hMovies);
		nField	= numel(cField);
		
		strNameMovie	= [];
		for kF=1:nField
			if hMovies.(cField{kF})==hMovie
				strNameMovie	= cField{kF};
				
				break;
			end
		end
		
		varargout{1}	= strNameMovie;
	end
end
