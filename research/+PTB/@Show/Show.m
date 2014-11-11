classdef Show < PTB.Object
% PTB.Show
% 
% Description:	use to show stimuli on the window
% 
% Syntax:	shw = PTB.Show(parent)
% 
% 			subclasses:
%				FixationTask:	object to show a fixation task during stimulus
%								sequences
%				Movie:			object to show movies
%
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Blank:				blank the window
%				Color:				show a color
%				Texture:			show a texture
%				TextureGrid:		show a grid of textures
% 				Fixation:			show a fixation point
%				Line:				show a line
%				Arrow:				show an arrow
%				Circle:				show a circle
%				Rectangle:			show a rectangle
%				Ring:				show a ring
%				Frame:				show a frame
%				Image:				show an image
%				ImageGrid:			show a grid of images
%				Text:				show text
%				Sequence:			show a sequence of stimuli
%				Loop:				show a stimulus loop
%				Instructions:		show instructions and wait for the subject's
%									response
%				Comic:				show a comic
%				Cute:				show a cute movie loop
%				Prompt:				show a prompt for input
%				RSVP:				show an RSVP stream
%				Timer:				show a frame of a timer countdown
% 
% In:
%	parent	- the parent object
% 	<options>:
%		fixation_size:		(1/4) the size of the fixation dot, in degrees of
%							visual angle, or false to not show a fixation dot
%		fixation_color:		('red') the color of the fixation dot
%		fixation_task_color	('deepskyblue') the color of the fixation task dot
%		fixation_task_rate:	(1/5) the average rate at which the fixation task
%							will be shown during each Show.Sequence, in Hz
%		fixation_task_dur:	(250) the duration of the fixation task, in
%							milliseconds
%		text_family:		('Courier New') the default font family
%		text_size:			(<0.5 for fmri context, 1 otherwise>) the default
%							text size, in degrees of visual angle for the letter
%							m
%		text_style:			('bold') the default text style
%		text_align:			('center') the default text alignment
%		text_color:			('black') the default text color
%		text_back:			('none') the default text background color
% 
% Updated: 2012-06-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		Key;
		
		FixationTask;
		Movie;
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
		function shw = Show(parent)
			shw	= shw@PTB.Object(parent,'show');
			
			shw.FixationTask	= PTB.Show.FixationTask(parent);
			shw.Movie			= PTB.Show.Movie(parent);
		end
		%----------------------------------------------------------------------%
		function Start(shw,varargin)
		%initialize the show object
			%parse the options
				opt	= ParseArgs(varargin,...
						'fixation_size'			, 1/4			, ...
						'fixation_color'		, 'red'			, ...
						'text_family'			, 'Courier New'	, ...
						'text_size'				, []			, ...
						'text_style'			, 'bold'		, ...
						'text_align'			, 'center'		, ...
						'text_color'			, 'black'		, ...
						'text_back'				, 'none'		  ...
						);
				
				if isempty(opt.text_size)
					opt.text_size	= switch2(shw.parent.Info.Get('experiment','context'),...
										'fmri'	, 0.5	, ...
												  1		  ...
										);
				end
				
				%set some info
					shw.parent.Color.Set('fixation',opt.fixation_color,'replace',false);
					
					shw.parent.Info.Set('show',{'fixation','size'},opt.fixation_size,'replace',false);
					
					shw.parent.Info.Set('show',{'text','family'},opt.text_family,'replace',false);
					shw.parent.Info.Set('show',{'text','size'},opt.text_size,'replace',false);
					shw.parent.Info.Set('show',{'text','style'},opt.text_style,'replace',false);
					shw.parent.Info.Set('show',{'text','align'},opt.text_align,'replace',false);
					shw.parent.Info.Set('show',{'text','color'},opt.text_color,'replace',false);
					shw.parent.Info.Set('show',{'text','back'},opt.text_back,'replace',false);
					
					
					strDirShow	= PathGetDir(mfilename('fullpath'));
					strDirImage	= DirAppend(strDirShow,'images');
					strDirComic	= DirAppend(strDirImage,'comics');
					strDirCute	= DirAppend(strDirImage,'cute');
					strDirShort	= DirAppend(strDirImage,'shorts');
					
					shw.parent.File.SetDirectory('show',strDirShow,'replace',false);
					shw.parent.File.SetDirectory('show_image',strDirImage,'replace',false);
					shw.parent.File.SetDirectory('show_comic',strDirComic,'replace',false);
					shw.parent.File.SetDirectory('show_cute',strDirCute,'replace',false);
					shw.parent.File.SetDirectory('show_short',strDirShort,'replace',false);
					
					shw.parent.File.Set('comic_sequence','show_comic','sequence.mat','replace',false);
					shw.parent.File.Set('cute_sequence','show_cute','sequence.mat','replace',false);
					shw.parent.File.Set('short_sequence','show_short','sequence.mat','replace',false);
					
					shw.parent.File.Set('char','show_image','char.mat','replace',false);
					
					p_LoadComicSequence(shw);
					p_LoadCuteSequence(shw);
					p_LoadShortSequence(shw);
					p_LoadCharacters(shw);
					
				%set up the keyboard for checking for keys
					strInputMode	= shw.parent.Info.Get('experiment','input');
					if ~isequal(strInputMode,'keyboard')
						shw.Key	= PTB.Device.Input.Keyboard(shw.parent);
						shw.Key.Start;
					else
						shw.Key	= shw.parent.Input;
					end
				
				%start the subclasses
					shw.FixationTask.Start(varargin{:});
					shw.Movie.Start(varargin{:});
				
				%show the fixation dot
					shw.Fixation;
				%flip
					shw.parent.Window.Flip('show start');
		end
		%----------------------------------------------------------------------%
		function End(shw,varargin)
		%end the show object
			%save the updated comic sequence
				p_SaveComicSequence(shw);
			%save the updated cute sequence
				p_SaveCuteSequence(shw);
			%save the updated short sequence
				p_SaveShortSequence(shw);
			%end the subclasses
				shw.Movie.End(varargin{:});
				shw.FixationTask.End(varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
