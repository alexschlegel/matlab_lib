function bPlaying = ShowFrame(mov,varargin)
% PTB.Show.Movie.ShowFrame
% 
% Description:	show the next movie frame
% 
% Syntax:	bPlaying = mov.ShowFrame([rect]=<all>,[p]=<center/top-left>,[s]=<no resize>,[a]=0,<options>)
%
% In:
%	[rect]		- the rect of the portion of the movie texture to show
%	[p]			- the (x,y) coordinates of the movie texture on the destination
%				  window, in degrees of visual angle
%	[s]			- the (w,h) size of the movie texture on the destination window,
%				  in degrees of visual angle.  a single value may be specified to
%				  fit the texture within a square box of that size.
%	[a]			- the rotation of the movie texture about its center, in
%				  clockwise degrees from vertical
%	<options>:
%		name:	('movie') the name of the movie
%		wait:	(true) wait to show the frame until the proper time according
%				to the playback rate
%		window:	('main') the name of the window on which to show the movie
%				texture
%		center:	(true) true if given coordinates are relative to the screen
%				center
%
% Out:
%	bPlaying	- true if the movie is still playing
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
						'name'		, []	, ...
						'wait'		, []	, ...
						'window'	, []	, ...
						'center'	, true	  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<2 || (isnumeric(varargin{1}) && (nargin<3 || (isnumeric(varargin{2}) && (nargin<4 || (isnumeric(varargin{3}) && (nargin<5 || (isnumeric(varargin{4}) && nargin<6)))))))
	%if nargin<7 && (nargin<3 || isnumeric(varargin{1})) && (nargin<4 || isnumeric(varargin{2})) && (nargin<5 || isnumeric(varargin{3})) && (nargin<6 || isnumeric(varargin{4}))
		bDefaults	= true;
		
		[rect,p,s,a]	= ParseArgs(varargin,[],[0 0],[],0);
	else
		bDefaults	= false;
		
		[rect,p,s,a,opt]	= ParseArgs(varargin,[],[0 0],[],0,cOptDefault{:});
	end

%get the frame
	if bDefaults
		hTexture	= mov.GetFrame();
	else
		hTexture	= mov.GetFrame('name',opt.name,'wait',opt.wait);
	end

bPlaying	= hTexture>0;

if bPlaying
	%show it
		if bDefaults
			mov.parent.Show.Texture(hTexture,rect,p,s,a);
		else
			mov.parent.Show.Texture(hTexture,rect,p,s,a,'window',opt.window,'center',opt.center);
		end
	%close the frame texture
		Screen('Close', hTexture);
end
