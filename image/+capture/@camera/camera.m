classdef camera < capture.base
% capture.camera
% 
% Description:	an object for controlling a digital camera with gphoto2 (based
%				off capture.base). cameras support the following settings
%				(default values in brackets):
%	s45:
%		iso:
%			[50], 100, 200, 400
%		shutterspeed:
%			1/1250, 1/1000, 1/800, 1/640, 1/500, 1/400, 1/320, 1/250, 1/200,
%			1/160, [1/125], 1/100, 1/80, 1/60, 1/50, 1/40, 1/30, 1/25, 1/20,
%			1/15, 1/13, 1/10, 1/8, 1/6, 1/5, 1/4, 0.3, 0.4, 0.5, 0.6, 0.8, 1,
%			1.3, 1.6, 2, 2.5, 3.2, 4, 5, 6, 8, 10, 13, 15
%		aperture:
%			2.8, 3.2, 3.5, ([4.0], 4.5, 5.0, 5.6, 6.3, 7.1, 8 if > 1/1000
%			shutter speed)
%		exposurecompensation:
%			-2 to 2 in increments of 1/3 (0 default)
% 
% Syntax:	cam = capture.camera(<options>)
% 
% 			properties:
%				model:	(r) the camera model
%				mode:	(rw) the current camera mode ('auto' or 'manual')
%				iso:	(rw) the current ISO value
%				shutterspeed:	(rw) the current shutter speed
%				aperture:	(rw) the current aperture
%				exposurecompensation:	(rw) the current exposure compensation
%				flash:	(rw) the current flash mode (1: on, 0: off, -1: auto)
%				isos:	(r) the allowed ISO values
%				shutterspeeds:	(r) the allowed shutter speeds
%				apertures:	(r) the allowed apertures
%				exposurecompensations:	(r) the allowed exposure compensations
% 
% In:
% 	<options>:
%		model:					('s45') one of the following:
%									's45': Canon PowerShot S45
%		mode:					('auto') 'auto' to automatically choose camera
%								settings, 'manual' to use the specified values
%		iso						(<see above>) the initial ISO value
%		shutterspeed:			(<see above>) the initial shutter speed, in s
%		aperture:				(<see above>) the initial aperture
%		exposurecompenation:	(<see above>) the initial exposure compensation
%		flash:					(0) the initial flash mode
%
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		mode	= '';
		
		iso						= 0;
		shutterspeed			= 0;
		aperture				= 0;
		exposurecompensation	= 0;
		flash					= 0;
	end
	properties (SetAccess=protected)
		model	= '';
		
		isos					= [];
		shutterspeeds			= [];
		apertures				= [];
		exposurecompensations	= [];
	end
	properties (Constant, SetAccess=protected)
		CAPTURE_TIMEOUT = 20000;
	end
	
	methods
		function cam = set.mode(cam,val)
			cam.mode	= CheckInput(val,'shooting mode',{'auto','manual'});
		end
		function cam = set.iso(cam,val)
			cam.iso	= CheckInput(val,'ISO value',cam.isos);
		end
		function cam = set.shutterspeed(cam,val)
			cam.shutterspeed	= CheckInput(val,'shutter speed',cam.shutterspeeds,'f_disp',@cam.p_DispShutterSpeed);
		end
		function cam = set.aperture(cam,val)
			cam.aperture	= CheckInput(val,'aperture',cam.apertures);
		end
		function cam = set.exposurecompensation(cam,val)
			
			cam.exposurecompensation	= CheckInput(val,'exposure compensation',cam.exposurecompensations,'f_disp',@cam.p_DispExposureCompensation);
		end
		function cam = set.flash(cam,val)
			cam.flash	= CheckInput(val,'flash mode',-1:1);
		end
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties(SetAccess=protected, GetAccess=protected)
		temp_dir		= '';
		path_downloaded	= '';
		
		gphoto2_pid		= [];
		
		default_iso						= 0;
		default_shutterspeed			= 0;
		default_aperture				= 0;
		default_exposurecompensation	= 0;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function cam = camera(varargin)
			cam	= cam@capture.base(varargin{:});
			
			%parse input options
				opt	= ParseArgs(varargin,...
						'model'					, 's45'		, ...
						'mode'					, 'auto'	, ...
						'iso'					, []		, ...
						'shutterspeed'			, []		, ...
						'aperture'				, []		, ...
						'exposurecompensation'	, []		, ...
						'flash'					, 0			  ...
						);
				
				cam.model		= CheckInput(opt.model,'camera model',{'s45'});
				cam.mode		= opt.mode;
				cam.flash		= opt.flash;
				
				switch cam.model
					case 's45'
						cam.ext	= 'jpg';
						
						cam.isos					= [50 100 200 400]';
						cam.shutterspeeds			= [1/1250, 1/1000, 1/800, 1/640, 1/500, 1/400, 1/320, 1/250, 1/200, 1/160, 1/125, 1/100, 1/80, 1/60, 1/50, 1/40, 1/30, 1/25, 1/20, 1/15, 1/13, 1/10, 1/8, 1/6, 1/5, 1/4, 0.3, 0.4, 0.5, 0.6, 0.8, 1, 1.3, 1.6, 2, 2.5, 3.2, 4, 5, 6, 8, 10, 13, 15]';
						cam.apertures				= [2.8, 3.2, 3.5, 4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8]';
						cam.exposurecompensations	= (-2:1/3:2)';
						
						cam.default_iso						= 50;
						cam.default_shutterspeed			= 1/125;
						cam.default_aperture				= 4;
						cam.default_exposurecompensation	= 0;
				end
				
				cam.iso						= unless(opt.iso,cam.default_iso);
				cam.shutterspeed			= unless(opt.shutterspeed,cam.default_shutterspeed);
				cam.aperture				= unless(opt.aperture,cam.default_aperture);
				cam.exposurecompensation	= unless(opt.exposurecompensation,cam.default_exposurecompensation);
			
			%get the capture directory
				cam.temp_dir		= GetTempDir();
				cam.path_downloaded	= PathUnsplit(cam.temp_dir,'downloaded','');
		end
		function delete(cam)
			rmdir(cam.temp_dir,'s');
		end
	end
	methods (Static)
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		function [im,t,strPathIm] = p_DoCapture(cam,varargin)
			bWait	= ParseArgs(varargin,true);
			
			if bWait && FileExists(cam.path_downloaded)
				delete(cam.path_downloaded);
			end
			
			[ec,res]	= system(['kill -USR1 ' num2str(cam.gphoto2_pid)]);
			
			%wait until the capture is downloaded
				if bWait
					while ~FileExists(cam.path_downloaded)
						WaitSecs(0.1);
					end
					delete(cam.path_downloaded);
				end
			
			cPathFile	= FindFilesByExtension(cam.temp_dir,cam.ext);
			nFile		= numel(cPathFile);
			
			if nFile==0
				error('No image created!');
			end
			
			strPathIm	= cPathFile{end};
			im			= imread(strPathIm);
			t			= FileModTime(strPathIm);
			
			cellfun(@delete,cPathFile(1:end-1));
		end
		function p_CaptureError(cam)
			
		end
		function strPrefix = p_GetPrefix(cam)
			strPrefix	= ['cd "' cam.temp_dir '"; '];
		end
		function strSuffix = p_GetSuffix(cam)
			switch cam.mode
				case 'auto'
					cSuffix	=	{
									'--set-config-index /main/settings/shootingmode=1'
							};
				case 'manual'
					cSuffix	=	{
									'--set-config-index /main/settings/shootingmode=4'
									['--set-config /main/settings/iso=' num2str(cam.iso)]
									['--set-config /main/settings/shutterspeed=' num2str(cam.shutterspeed)]
									['--set-config /main/settings/aperture=' num2str(cam.aperture)]
									['--set-config-index /main/settings/exposurecompensation=' num2str(round(MapValue(cam.exposurecompensation,-2,2,0,16)))]
									
							};
			end
			
			cSuffix	=	[cSuffix
							['--set-config-index /main/settings/flashmode=' switch2(cam.flash,1,'1',0,'0',-1,'2')]
							'--capture-image-and-download'
							'--force-overwrite'
						];
			
			strSuffix	= join(cSuffix,' ');
		end
		
		function str = p_DispShutterSpeed(cam,ss)
			if ss>0.25
				str	= num2str(ss);
			else
				str	= num2frac(ss);
			end
		end
		function str = p_DispExposureCompensation(cam,ec)
			str	= num2frac(ec);
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
