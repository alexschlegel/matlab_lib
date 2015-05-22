classdef Window < PTB.Object
% PTB.Window
% 
% Description:	use to open, manipulate, and close a stimulus presentation window
% 
% Syntax:	win = PTB.Window(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Get:				get info about a named window
%				Set:				set the handle of a named window
%				Open:				open the window
%				Close:				close the window
%				OpenTexture:		open a named texture
%				CloseTexture:		close a named texture
%				BlockMonitor:		open a semi-transparent screen over a
%									monitor.  useful for preventing subjects
%									from affecting the computer.
%				UnblockMonitor:		close the blocking window on a previously
%									blocked monitor
%				SetStore:			set whether flip should store the buffer
%									before flipping
%				OverrideStore:		override the SetStore setting for the next
%									flip
%				Store:				store the current window contents in the
%									hidden copy
%				Recall:				recall the hidden copy contents to the main
%									window
% 				va2px:				convert degrees of visual angle to pixels
%				px2va:				convert pixels to degrees of visual angle
%
%			properties:
%				occludes (get only):	true if the main window occludes the
%					MATLAB command window
% 
% In:
%	parent	- the parent object
% 	<options>:
%		fullscreen:		(<auto>) true to open the window full screen
%		background:		('gray') the background color
%		screendim:		(<auto>) the [width height] dimensions of the stimulus
%						screen, in meters.  defaults:
%							fmri:			0.43*[1 3/4] (projector image is 43cm
%											wide)
%							eeg:			ConvertUnit([16 12],'inch','m')
%							psychophysics:	ConvertUnit([16 12],'inch','m')
%		distance:		(<auto>) the distance from the screen to the subject, in
%						meters.  defaults:
%							fmri:			1.07 (10cm eye to mirrow, 97cm mirror
%											to screen)
%							eeg:			0.5
%							psychophysics:	0.5
%		closetextures:	(false) if true, CloseTexture actually closes textures.
%						if false, CloseTexture save textures for later calls to
%						OpenTexture. this is an attempt to limit the amount of
%						textures that are opened as a work around to some
%						graphics drivers that apparently don't ever close
%						textures.  unless you will be using many different sized
%						textures, leave this set to false.
%		block_default:	(<depends on monitor setup>) the default monitor to
%						block (see BlockMonitor). set to 0 to skip blocking of
%						windows.
%		visualdebug:	(false) false to disable visual debugging (e.g. big
%						pulsing warning sign) (visual debug level 0).  true to
%						enable (visual debug level 4)
%		skipsynctests:	(false) true to skip the sync tests PsychToolbox
%						performs when opening a new window (see help
%						SyncTrouble)
%		screentohead:	(<auto>) manually specify the ptb screentohead
%						preference (see
%						http://tech.groups.yahoo.com/group/psychtoolbox/message/14216)
% 
% Updated: 2013-09-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (Dependent, SetAccess=private)
		occludes;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function bOccludes = get.occludes(win)
			bOccludes	=	notfalse(win.parent.Info.Get('window','monitor')==1) && ...
							notfalse(win.parent.Info.Get('window','fullscreen')) && ...
							~isempty(win.parent.Info.Get('window',{'h','main'}));
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function win = Window(parent)
			win	= win@PTB.Object(parent,'window');
		end
		%----------------------------------------------------------------------%
		function Start(win,varargin)
		%initialize a window
			%parse the options
				opt	= ParseArgs(varargin,...
						'fullscreen'	, []		, ...
						'background'	, 'gray'	, ...
						'screendim'		, []		, ...
						'distance'		, []		, ...
						'closetextures'	, false		, ...
						'block_default'	, 1			, ...
						'visualdebug'	, false		, ...
						'skipsynctests'	, false		, ...
						'screentohead'	, []		  ...
						);
			
			%scanner screen is 22.72 deg. visual angle wide and 17.14 d.v.a. tall
			strContext	= win.parent.Info.Get('experiment','context');
			if isempty(opt.screendim)
				opt.screendim	= switch2(strContext,...
									'fmri'			, 0.43*[1 3/4]						, ...
									'eeg'			, ConvertUnit([16 12],'inch','m')	, ...
									'psychophysics'	, ConvertUnit([16 12],'inch','m')	  ...
									);
			end
			if isempty(opt.distance)
				opt.distance	= switch2(strContext,...
									'fmri'			, 1.07	, ...
									'eeg'			, 0.5	, ...
									'psychophysics'	, 0.5	  ...
									);
			end
				
			%set some info
				win.parent.Info.Set('window','nsetstore',0,'replace',false);
				win.parent.Info.Set('window','overridestore',[],'replace',false);
				
				win.parent.Info.Set('window','bcapture',false,'replace',false);
				win.parent.Info.Set('window','capture_dir',false,'replace',false);
				win.parent.Info.Set('window','capture_rate',[],'replace',false);
				win.parent.Info.Set('window','capture_time',0,'replace',false);
				
				win.parent.Info.Set('window','distance',opt.distance,'replace',false);
				win.parent.Info.Set('window','screendim',opt.screendim,'replace',false);
				
				win.parent.Info.Set('window','closetextures',opt.closetextures,'replace',false);
				win.parent.Info.Set('window','visualdebug',opt.visualdebug,'replace',false);
				win.parent.Info.Set('window','skipsynctests',opt.skipsynctests,'replace',false);
				win.parent.Info.Set('window','skipsynctests',opt.screentohead,'replace',false);
				
				%get the main window size and location
					bFull	= unless(opt.fullscreen,conditional(win.parent.Info.Get('experiment','debug')<2,true,[]));
					win.parent.Info.Set('window','fullscreen',bFull,'replace',false);
					bFull	= win.parent.Info.Get('window','fullscreen');
					[kMonitor,pWindow,sWindow]	= p_GuessWindow(bFull);
				
					win.parent.Info.Set('window','monitor',kMonitor,'replace',false);
					win.parent.Info.Set('window','position',pWindow,'replace',false);
					win.parent.Info.Set('window','size',sWindow,'replace',false);
				%get the monitor to block
					if isempty(opt.block_default)
						[nMonitor,resMonitor,pMonitor]	= GetMonitorInfo;
						
						if nMonitor==1
						%only on monitor, don't block anything
							kBlock	= 0;
						elseif win.parent.info.Get('window','monitor')==1
						%probably won't happen
							kBlock	= 2;
						else
						%multiple monitors, block the first
							kBlock	= 1;
						end
					else
					%do whatever master says
						kBlock	= opt.block_default;
					end
					
					win.parent.Info.Set('window','block_default',kBlock,'replace',false);
				
				win.parent.Info.Set('window','flips',0,'replace',false);
				
				win.parent.Color.Set('background',opt.background,'replace',false);
				
				%other objects can set this do indicate whether flip should store
				%the current state before flipping
					win.parent.Info.Set('window','store',false,'replace',false);
				
				%for keeping track of textures
					win.parent.Info.Set('window',{'texture','active'},[],'replace',false);
					win.parent.Info.Set('window',{'texture','height'},[],'replace',false);
					win.parent.Info.Set('window',{'texture','width'},[],'replace',false);
					win.parent.Info.Set('window',{'texture','h'},[],'replace',false);
			
			%close all windows
				sca;
			%open the window
				win.Open;
			
			%set some more info
				%calculate the pixel density
					[h,sz]	= win.Get('main');
					m		= win.parent.Info.Get('window','screendim');
					dpm		= mean(sz./m);
					
					win.parent.Info.Set('window','dpm',dpm,'replace',false);
		end
		%----------------------------------------------------------------------%
		function End(win,varargin)
			%unblock monitors
				win.UnblockMonitor;
			%close the windows
				win.Close;
			%close everything else
				sca;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
