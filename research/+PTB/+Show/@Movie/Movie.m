classdef Movie < PTB.Object
% PTB.Show.Movie
% 
% Description:	use to show movies
% 
% Syntax:	ft = PTB.Show.Movie(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Open:				open a movie file
%				Close:				close a movie file
%				Get:				get the handle to a movie
%				Play:				start playing a movie
%				Stop:				stop playing a movie
%				Seek:				seek to a specific movie position
%				ShowFrame:			show the next frame of a movie
%				GetFrame:			get the next frame of a movie
% 
% In:
%	parent	- the parent PTB.Experiment object
%
% Example:
%	strPathMovie = '/home/alex/Media/Video/Movies/Barbarella.avi';
%	ptb.Show.Movie.Open(strPathMovie);
%	ptb.Show.Movie.Play;
%	a=0; p=[0 0]; while ptb.Show.Movie.ShowFrame([],p,20*(1.1+sin(10*d2r(a))),a), ptb.Window.Flip; a=mod(a+1,360); p=10*[cos(3*d2r(a)),sin(3*d2r(a))]; end;
%	ptb.Show.Movie.Close;
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function mov = Movie(parent)
			mov	= mov@PTB.Object(parent,'movie');
		end
		%----------------------------------------------------------------------%
		function Start(mov,varargin)
		%initialize the Movie object
			mov.parent.Info.Set(mov.type,'h',struct,'replace',false);
			mov.parent.Info.Set(mov.type,'path',struct,'replace',false);
			mov.parent.Info.Set(mov.type,'rate',struct,'replace',false);
			mov.parent.Info.Set(mov.type,'window',struct,'replace',false);
		end
		%----------------------------------------------------------------------%
		function End(mov,varargin)
		% end the Movie object
			%get the movie names
				cMovies	= fieldnames(mov.parent.Info.Get(mov.type,'h'));
			%close all the movies
				cellfun(@(m) mov.Close(m),cMovies);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
