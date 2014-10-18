classdef Info < Group.Object
% Group.Info
% 
% Description:	object to share information among a Group
% 
% Syntax:	ifo = Group.Info(parent,[strType]='info')
% 
% 			subfunctions:
%				<see Group.Object>
%				Set:		set info
%				Unset:		unset info
%				Get:		get info
%				Save:		save the info struct to file
%				AutoSave:	start autosaving the info struct
%				Load:		load the info struct from file
%
%			properties:
%				<see Group.Object>
%				name:	set the name of the info struct
% 
% In:
%	parent		- the parent object
%	[strType]	- the type of the object
% 	<start options>:
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties 
		name;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function ifo = set.name(ifo,strName)
			ifo.parent.File.Set('info','data',[strName '.mat']);
				
			%set the new info struct path
				ifo.parent.File.Set('info','data',[strName '.mat']);
			%check to see if the info path already exists
				strPathInfo	= ifo.File.Get('info');
				
				if FileExists(strPathInfo)
					dbg			= ifo.root.Info.Get('debug');
					strDefault	= conditional(dbg==2,'overwrite','load');
					
					res	= ifo.parent.Prompt.Ask(['Info for ' strName ' already exists in "' strPathInfo '".  What should we do?'],'choice',{'load','abort','overwrite'},'default',strDefault);
					switch res
						case 'load'
							ifo.Load;
						case 'abort'
							ifo.root.Abort;
						case 'overwrite'
							delete(strPathInfo);
					end
				end
			%save the struct
				strStatus	= ['Info struct saving to: "' strPathInfo '"'];
				ifo.parent.Status.Show(strStatus,'time',false);
				
				ifo.Save;

			ifo.name	= strName;
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function ifo = Info(parent,varargin)
			[strType,opt]	= ParseArgs(varargin,'info',...
								'attach_class'	, {'Info'}	, ...
								'attach_name'	, []		, ...
								'attach_arg'	, []		  ...
								);
			cOpt			= opt2cell(opt);
			
			ifo	= ifo@Group.Object(parent,strType,cOpt{:});
		end
		%----------------------------------------------------------------------%
		function Start(ifo,varargin)
		%start the info object
			if ~ifo.root.IsProp('info') || isempty(ifo.root.info)
				ifo.Clear;
			end
			
			Start@Group.Object(ifo,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(ifo,varargin)
		%end the info object
			%save one last time
				if ifo.parent.IsProp('File')
					strPathInfo	= ifo.parent.File.Get('info');
					
					if ~isequal(strPathInfo,'info')
						ifo.Save;
						
						strStatus	= ['Info struct saved to: "' strPathInfo '"'];
						
						ifo.parent.Status.Show(strStatus,'time',false);
					end
				end
			
			End@Group.Object(ifo,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
