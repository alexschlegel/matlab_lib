classdef Log < handle
% Log
% 
% Description:	log information
% 
% Syntax:	L = Log(<options>)
% 
% 			methods:
%				Print:		print some information
%				CheckLevel:	check whether a messages should be shown at the
%							current level
% 
% 			properties:
%				name:	a name to prepend to messages
% 				level:	the debug level, determines which log messages actually
%						get logged
%				ms:		true to show milliseconds
%				silent:	true to suppress all status messages
% 
% In:
% 	<options>:
%		name:		([]) the initial value of the name property
%		level:		('error') the level of log messages (can be 'error', 'warn',
%					'info', 'most', or 'all')
%		ms:			(false) true to show milliseconds
%		silent:		(false) true to suppress all status messages
% 
% Updated: 2015-06-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		name	= [];
		level	= [];
		ms		= [];
		silent	= [];
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		kLevel	= [];
	end
	properties (GetAccess=protected, Constant)
		LEVELS	=	{
						'all'
						'most'
						'info'
						'warn'
						'error'
					};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function L = set.level(L, value)
			[L.level,L.kLevel]	= L.CheckLevel(value);
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function L = Log(varargin)
			opt	= ParseArgs(varargin,...
					'name'		, []		, ...
					'level'		, 'error'	, ...
					'ms'		, false		, ...
					'silent'	, false		  ...
					);
			
			L.name		= opt.name;
			L.level		= opt.level;
			L.ms		= opt.ms;
			L.silent	= opt.silent;
		end
		%----------------------------------------------------------------------%
		function Print(L,str,varargin)
		%L.Print(str,[level]='info',['exception', me]): print some info at the
		%specified debug level, optionally including info about an exception
			if numel(varargin)>0
				level	= varargin{1};
				
				if numel(varargin)>2 && strcmp(varargin{2},'exception')
					opt	= struct('exception',varargin{3});
				else
					opt	= struct('exception',[]);
				end
			else
				level	= 'info';
				opt		= struct('exception',[]);
			end
			
			if L.TestLevel(level)
				bWarn		= L.TestLevel(level,'warn');
				bException	= ~isempty(opt.exception);
				
				if bException
					str	= sprintf('%s (%s):',str,opt.exception.identifier);
				end
				
				if ~isempty(L.name)
					str	= sprintf('%s: %s',L.name,str);
				end
				
				status(str,0,...
					'warning'	, bWarn		, ...
					'ms'		, L.ms		, ...
					'silent'	, L.silent	  ...
					);
				
				if bException
					fprintf(2,opt.exception.getReport);
				end
			end
		end
		%----------------------------------------------------------------------%
		function b = TestLevel(L, level,varargin)
		%L.TestLevel(level,[levelCompare]=L.level): test whether the specified
		%	level is at or above the comparison level
			if numel(varargin)>0
				levelCompare	= varargin{1};
			else
				levelCompare	= [];
			end
			
			if isempty(levelCompare)
				kLevelCompare	= L.kLevel;
			else
				[levelCompare,kLevelCompare]	= L.CheckLevel(levelCompare);
			end
			
			[level,kLevel]	= L.CheckLevel(level);
			
			b				= kLevel >= kLevelCompare;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		function [level,kLevel] = CheckLevel(L, level)
			kLevel	= find(strcmp(level,L.LEVELS),1);
			
			assert(~isempty(kLevel),'%s is an invalid level',level); 
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
