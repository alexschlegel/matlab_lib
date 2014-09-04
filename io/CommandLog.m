% CommandLog
% 
% Description:	an object that logs the command history.
% 
% Syntax:	cl = CommandLog([strPathLog]='',<options>)
%			Properties:
%				path	- path to the log file (r/w)
%				logging	- boolean value indicating whether the object is
%						  currently logging commands (r)
%				log		- current contents of the log (r)
%			Methods:
%				Start	- start logging
%				Stop	- stop logging
%				Update	- update the log
%				Reset	- reset the log
% 
% In:
% 	[strPathLog]	- path to the log file to write.  if unspecified, the object
%					  will store the log but not save it to a file until one is
%					  specified through the .path property
%	<options>:
%		'append':	(true) true to append to log files that already exist, false
%					to overwrite them
%		'start':	(true) true to start the log at the time of object creation
%		'root':		(true) true if the object is being created from the root
%					MATLAB command prompt.  This determines whether or not calls
%					to CommandLog functions will show up in the command history.
% 
% Out:
% 	cl	- an instance of the CommandLog object
% 
% Updated:	2009-07-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
classdef CommandLog < handle
	%public properties
	properties
		%path to the log file
			path;
	end
	%read-only properties
	properties (SetAccess=private)
		%is the object logging commands?
			logging	= false;
		%contents of the log
			log		= '';
	end
	%private properties
	properties (Access=private)
		%should the log file be appended?
			append;
		%was the object created from the command prompt?
			root;
		%initial value of the log file
			initialLogValue	= '';
		%last queried value of the command history file
			CHCur = '';
		%path to the command history file
			pathCH			= [prefdir '\history.m'];
	end
	%public methods
	methods
		function cl = CommandLog(varargin)
		%constructor function
			[strPathLog,opt]	= ParseArgsOpt(varargin,'',...
								'append'	, true	, ...
								'start'		, true	, ...
								'root'		, true	  ...
								);
			cl.append	= opt.append;
			cl.root		= opt.root;
			cl.path		= strPathLog;
			
			if opt.start
				cl.Start;
			end
		end
		function Start(cl)
		%start logging
			cl.logging	= true;
			cl.CHCur	= cl.ReadCH;
		end
		function Stop(cl)
		%stop logging
			cl.Update;
			cl.logging	= false;
		end
		function Update(cl)
		%update the log
			if cl.logging
				%get the start of the current log addition (end of the last
				%update position)
					strCHOld	= cl.CHCur;
					kCHStart	= numel(strCHOld)+1;
				%get the current command history
					cl.CHCur	= cl.ReadCH;
				%get the end of the current log addition (before the last
				%command history line if cl.root==true)
					if cl.root
						kLF		= find(cl.CHCur==10,2,'last');
						switch numel(kLF)
							case 2
								if kLF(2)==numel(cl.CHCur)
									kCHEnd	= kLF(1);
								else
									kCHEnd	= kLF(2);
								end
							case {0,1}
								kCHEnd	= 0;
						end
					else
						kCHEnd	= numel(cl.CHCur);
					end
				%append the log
					cl.Append(cl.CHCur(kCHStart:kCHEnd));
			end
		end
		function Reset(cl)
		%reset the log
			cl.log = cl.initialLogValue;
		end
		
		%property methods
		function cl = set.path(cl,strPathLog)
			cl.path	= strPathLog;
			
			if cl.append && isfile(strPathLog)
				cl.initialLogValue	= cl.ReadLog;
				cl.log			= [cl.initialLogValue cl.log];
			else
				cl.log	= cl.log;
			end
			
			cl.Update;
		end
		function cl = set.log(cl,strLog)
			cl.log	= strLog;
			
			if ~isempty(cl.path)
				cl.WriteLog;
			end
		end
	end
	%private methods
	methods (Access=private)
		function Append(cl,strEntry)
		%append the log
			cl.log	= [cl.log strEntry];
		end
		function strCH = ReadCH(cl)
		%read the current command history
			%read it
				strCH	= fget(cl.pathCH);
			%replace CRLF with LF
				strCH	= regexprep(strCH,'\r\n','\n');
		end
		function strLog = ReadLog(cl)
		%read the current log file
			%read it
				strLog	= fget(cl.path);
			%replace CRLF with LF
				strLog	= regexprep(strLog,'\r\n','\n');
		end
		function WriteLog(cl)
		%write the current log file
			%make sure the file has the correct line breaks
				strLog	= cl.log;
				if ispc
					strLog	= regexprep(strLog,'\r','\r\n');
				end
			%write it
				fput(strLog,cl.path);
		end
	end
end
