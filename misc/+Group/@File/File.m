classdef File < Group.Object
% Group.File
% 
% Description:	use to save and read files
% 
% Syntax:	f = Group.File(parent,[strType]='file')
% 
% 			subfunctions:
%				<see Group.Object>
%				GetDirectory:		get the path to a named directory
%				SetDirectory:		set the path to a name directory
%				Get:				get the path to a named file
%				Set:				set the path to a named file
%				Exists:				check to see if a named file exists
%				Write:				write data to a named file
%				Append:				append data to a named text file
%				AppendLine:			append a line to a named text file
%				Read:				read data from a named file
%				Open:				open a file for fast writing later
%				Close:				close a file opened with Group.File.Open
% 
% In:
%	parent		- the parent object
%	[strType]	- the type of the object
% 	<start options>:
%	 	base_dir:	(<auto>) the base directory for files
% 
% Updated: 2015-03-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function f = File(parent,varargin)
			[strType,opt]	= ParseArgs(varargin,'file',...
								'attach_class'	, []	, ...
								'attach_name'	, []	, ...
								'attach_arg'	, []	  ...
								);
			cOpt			= opt2cell(opt);
			
			f	= f@Group.Object(parent,strType,cOpt{:});
		end
		%----------------------------------------------------------------------%
		function Start(f,varargin)
		% initialize the file object
			opt	= ParseArgs(varargin,...
					'dir_base'	, []	  ...
					);
			
			if ~IsWritable(f.GetDirectory('base'))
			%no working base directory
				if ~isempty(opt.dir_base)
				%use the specified base directory
					f.SetDirectory('base',opt.dir_base,false);
				else
				%get the default base directory
					global strDirBase;
					
					if IsWritable(strDirBase)
					%someone set a base directory
						strDir	= strDirBase;
					elseif IsWritable(pwd)
					%just use the current directory
						strDir	= pwd;
					else
						strDirHome		= GetDirUser;
						strDirHomeTemp	= DirAppend(strDirHome,'temp');
						
						if IsWritable(strDirHomeTemp)
						%use the user's home/temp directory
							strDir	= strDirHomeTemp;
						elseif IsWritable(strDirHome)
						%just the user's home directory
							strDir	= strDirHome;
						elseif IsWritable(tempdir)
						%use the temp directory
							strDir	= tempdir;
						else
						%die!
							error('Could not find a writable base directory.');
						end
					end
					
					f.SetDirectory('base',strDir,false);
					f.SetDirectory('data',DirAppend(strDir,'data'),false);
					f.SetDirectory('code',DirAppend(strDir,'code'),false);
					f.SetDirectory('analysis',DirAppend(strDir,'analysis'),false);
				end
			end
			
			Start@Group.Object(f,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(f,varargin)
		% end the file object
			%close all open files
				fid		= f.Info.Get('fid');
				if ~isempty(fid)
					fid		= struct2array(fid);
					nFID	= numel(fid);
					
					for kF=1:nFID
						try
							%don't use f.Close here so that we treat it as opened
							%if we start back up again
							fclose(fid(kF));
						catch me
						end
					end
				end
			
			End@Group.Object(f,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
