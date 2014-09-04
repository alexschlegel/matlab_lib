function disarm(cam)
% capture.camera.disarm
% 
% Description:	disarm the camera
% 
% Syntax:	cam.disarm
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if cam.armed
	%take photos until the PID no longer exists
		while ispid(cam.gphoto2_pid)
			system(['kill -USR1 ' num2str(cam.gphoto2_pid)]);
			
			WaitSecs(0.5);
		end
	%delete the remaining photos
		cPathFile	= FindFilesByExtension(cam.temp_dir,cam.ext);
		cellfun(@delete,cPathFile);
	
	cam.gphoto2_pid	= [];
	
	disarm@capture.base(cam);
end
