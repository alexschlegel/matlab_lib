function x = video2frames(cPathVideo,varargin)
% video2frames
% 
% Description:	extract frames from video files
% 
% Syntax:	x = video2frames(cPathVideo,<options>)
% 
% In:
% 	cPathVideo	- a video file path or cell of video file paths
%	<options>:
%		outdir:		(<load>) to save the frames to files, specify the output
%					directory
%		outformat:	('jpg') the output file format
%		nthread:	(1) the number of video files to process simultaneously
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	x	- either a 4D array of video frames, or a cell of file paths, depending
%		  on whether <outdir> was specified
% 
% Updated: 2013-07-21
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
