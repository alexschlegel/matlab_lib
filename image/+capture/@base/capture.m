function [im,t] = capture(cap)
% capture.base.capture
% 
% Description:	capture an image from the capture device
% 
% Syntax:	[im,t] = cap.capture()
%
% Output:
%	im	- the image
%	t	- the nowms style time of image acquisition
% 
% Updated: 2013-07-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
for kTry=1:2
	%try
		bArm	= ~cap.armed;
		if bArm
			cap.arm(0);
		end
		
		[im,t,strPathIm]	= cap.p_DoCapture(~bArm);
		
		if isequal(cap.result.status,'running')
			strExtra	= [' (' num2str(cap.result.remaining-1) ' remaining)'];
		else
			strExtra	= '';
		end
		cap.status(['capture!' strExtra]);
		
		if ~isempty(cap.outdir)
			if cap.subdir
				strDirOut	= DirAppend(cap.outdir,FormatTime(t,'yyyymmdd'));
				CreateDirPath(strDirOut,'error',true);
			else
				strDirOut	= cap.outdir;
			end
			
			strFilePre	= FormatTime(t,'yyyymmddHHMMSSFFF');
			strPathOut	= PathUnsplit(strDirOut,strFilePre,cap.ext);
			
			bMove	= ~isempty(strPathIm);
			if bMove
				if ~movefile(strPathIm,strPathOut,'f')
					error('could not move the output image');
				end
			else
				imwrite(im,strPathOut);
			end
			
			cap.result.im{end+1}	= strPathOut;
		end
		
		if bArm
			cap.disarm;
		end
		
		return;
	%catch me
		cap.p_CaptureError();
	%end
end

im	= [];
t	= nowms;
