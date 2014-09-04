function arm(cam,nCapture)
% capture.camera.arm
% 
% Description:	prepare the camera for capturing
% 
% Syntax:	cam.arm(nCapture)
%
% In:
%	nCapture	- the number of captures to prepare for
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~cam.armed
	[ec,res]	= system('gvfs-mount -s gphoto2');
	%system('sudo gvfs-mount -s gphoto2');
	
	%get the current gphoto2 PIDs
		[ec,res]	= system('pidof gphoto2');
		PIDOld		= str2array(res);
	%prepare the script to tell us when the camera is actually armed
		strPathScript	= PathUnsplit(cam.temp_dir,'checkdownload','sh');
		
		if FileExists(cam.path_downloaded)
			delete(cam.path_downloaded);
		end
		
		fput(['#!/bin/sh' 10 'if [ $ACTION = "download" ]; then touch "' cam.path_downloaded '"; fi'],strPathScript);
		[ec,res]	= system(['chmod 755 ' strPathScript]);
	%now start gphoto2
		nFrame	= nCapture + 1;
		
		[ec,res]    = system([cam.p_GetPrefix() ' gphoto2 ' cam.p_GetSuffix() ' --interval -1 --frames ' num2str(nFrame) ' --hook-script "' strPathScript '" &']);
	%get the new PID
		[ec,res]		= system('pidof gphoto2');
		PIDNew			= str2array(res);
		cam.gphoto2_pid	= setdiff(PIDNew,PIDOld);
	%wait until the first capture is downloaded
		while ~FileExists(cam.path_downloaded)
			WaitSecs(0.1);
		end
		delete(cam.path_downloaded);
		
		if nFrame>1
		%kill them all!
			cPathFile	= FindFilesByExtension(cam.temp_dir,cam.ext);
			cellfun(@delete,cPathFile);
		end

	arm@capture.base(cam);
end
