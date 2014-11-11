classdef webcam < capture.base
% capture.webcam
% 
% Description:	an object for controlling a webcam (based off capture.base)
% 
% Syntax:	wc = capture.webcam(<options>)
% 
% 			properties:
%				vi	- the webcam's videoinput object
% 
% In:
% 	<options>:
%		adaptor:	(<'linuxvideo' or first>) the name of the adaptor to use
%		device:		(1) the name or number of the device to use
%		h:			(<max>) the desired frame height
%		w:			(<max>) the desired frame width
%
% Updated: 2013-07-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		vi;
		
		h = NaN;
		w = NaN;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties(SetAccess=private, GetAccess=private)
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function wc = webcam(varargin)
			wc	= wc@capture.base(varargin{:});
			
			%parse the input
				opt	= ParseArgs(varargin,...
						'adaptor'	, []	, ...
						'device'	, 1		, ...
						'h'			, []	, ...
						'w'			, []	  ...
						);
				
				%get the adaptor
					if isempty(opt.adaptor)
						cAdaptor		= capture.webcam.adaptors;
						
						strDefault	= 'linuxvideo';
						if ismember(strDefault,cAdaptor)
							opt.adaptor	= strDefault;
						elseif numel(cAdaptor)>0
							opt.adaptor	= cAdaptor{1};
						else
							error('no video adaptors exist.');
						end
					end
				%get the device number
					if ischar(opt.device)
						cDevice	= capture.webcam.devices(opt.adaptor);
						
						[b,kDevice]	= ismember(lower(opt.device),lower(cDevice));
						if ~b
							strDevice	= lower(opt.device);
							lenDevice	= numel(strDevice);
							bMatch		= cellfun(@(d) numel(d)>=lenDevice && isequal(lower(d(1:lenDevice)),strDevice),cDevice);
							
							if any(bMatch)
								kDevice	= find(bMatch,1);
							else
								error(['device not found in adaptor "' opt.adaptor '".']); 
							end
						end
						
						opt.device	= kDevice(1);
					end
				%get the frame size
					[hFrame,wFrame] = capture.webcam.framesizes(opt.adaptor,opt.device);
					
					opt.h	= unless(opt.h,hFrame);
					opt.w	= unless(opt.w,wFrame);
					
					fsDist	= (hFrame - opt.h).^2 + (wFrame - opt.w).^2;
					kFrame	= find(fsDist==min(fsDist));
					
					if numel(kFrame)>1
						fsArea	= hFrame(kFrame).*wFrame(kFrame);
						kFrame	= kFrame(find(fsArea==max(fsArea),1));
					end
					
					wc.h	= hFrame(kFrame);
					wc.w	= wFrame(kFrame);
			
			%create the video input object
				s		= getfield(imaqhwinfo(opt.adaptor,opt.device),'SupportedFormats');
				kFormat	= find(~cellfun(@isempty,regexp(s,[num2str(wc.w) 'x' num2str(wc.h) '$'])),1);
				
				wc.vi	= videoinput(opt.adaptor,opt.device,s{kFormat});
			%start it
				wc.p_VIStart();
		end
		function delete(wc)
			wc.p_VIStop;
			delete(wc.vi);
		end
	end
	methods (Static)
		function cAdaptor = adaptors()
		% webcam.adaptors
		% 
		% Description:	return all system video adaptor names
		% 
		% Syntax:	cAdaptor = webcam.adaptors()
		% 
		% Updated: 2013-07-20
		% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
		% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
		% License.
			cAdaptor	= reshape(getfield(imaqhwinfo,'InstalledAdaptors'),[],1);
		end
		function cDevice = devices(strAdaptor)
		% webcam.devices
		% 
		% Description:	return the names of devices associated with the given
		%				adaptor
		% 
		% Syntax:	cDevice = webcam.devices(strAdaptor)
		% 
		% Updated: 2013-07-20
		% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
		% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
		% License.
			s		= getfield(imaqhwinfo(strAdaptor),'DeviceInfo');
			cDevice	= reshape({s.DeviceName},[],1);
		end
		function [hFrame,wFrame] = framesizes(strAdaptor,kDevice)
		% webcam.framesizes
		% 
		% Description:	return the possible frame sizes for the given device
		% 
		% Syntax:	cDevice = webcam.devices(strAdaptor,kDevice)
		% 
		% Updated: 2013-07-20
		% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
		% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
		% License.
			s	= getfield(imaqhwinfo(strAdaptor,kDevice),'SupportedFormats');
			re	= regexp(s,'(?<w>\d+)x(?<h>\d+)$','names');
			re	= cat(1,re{:});
			
			hFrame	= reshape(cellfun(@str2num,{re.h}),[],1);
			wFrame	= reshape(cellfun(@str2num,{re.w}),[],1);
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		function [im,t,strPathIm] = p_DoCapture(wc,varargin)
			strPathIm	= '';
			
			nAvailableStart	= get(wc.vi,'FramesAvailable');
		
			trigger(wc.vi);
			
			nAvailable	= nAvailableStart;
			while nAvailable<nAvailableStart+1
				WaitSecs(0.001);
				nAvailable	= get(wc.vi,'FramesAvailable');
			end
			
			d	= getdata(wc.vi,nAvailable);
			im	= d(:,:,:,end);
			
			evt	= get(wc.vi,'EventLog');
			t	= datenum(evt(end).Data.AbsTime) * 86400000;
		end
		function p_CaptureError(wc)
			wc.p_VIStop();
			wc.p_VIStart();
		end
		function p_VIStart(wc)
			strDirMe	= PathGetDir(mfilename('fullpath'));
			strPathLog	= PathUnsplit(strDirMe,'log','daq');
			
			set(wc.vi,...
				'ReturnedColorSpace'	, 'RGB'			, ...
				'FramesPerTrigger'		, 1				, ...
				'Timeout'				, inf			, ...
				'TriggerRepeat'			, inf			  ...
				);
			
			triggerconfig(wc.vi,'manual')
			
			start(wc.vi);
		end
		function p_VIStop(wc)
			stop(wc.vi);
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
