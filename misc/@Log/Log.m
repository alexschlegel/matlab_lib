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
% 				level:	the debug level, determines which log messages actually
%						get logged
% 
% In:
% 	<options>:
%		level:		('error') the level of log messages (can be 'error', 'warn',
%					'info', 'most', or 'all')
%		silent:		(false) true to suppress all status messages
% 
% Updated: 2014-01-30
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		level	= [];
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
					'level'		, 'error'	, ...
					'silent'	, false		  ...
					);
			
			L.level		= opt.level;
			L.silent	= opt.silent;
		end
		%----------------------------------------------------------------------%
		function Print(L,str,varargin)
		%L.Print(str,[level]='info',['exception', me]): print some info at the
		%specified debug level, optionally including info about an exception
			[level,opt]	= ParseArgs(varargin,'info',...
							'exception'	, []	  ...
							);
			
			if L.TestLevel(level)
				bWarn		= L.TestLevel(level,'warn');
				bException	= ~isempty(opt.exception);
				
				if bException
					str	= sprintf('%s (%s):',str,opt.exception.identifier);
				end
				
				status(str,0,'warning',bWarn,'silent',L.silent);
				
				if bException
					fprintf(2,opt.exception.getReport);
				end
			end
		end
		%----------------------------------------------------------------------%
		function b = TestLevel(L, level,varargin)
		%L.TestLevel(level,[levelCompare]=L.level): test whether the specified
		%	level is at or above the comparison level
			levelCompare	= ParseArgs(varargin,[]);
			
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
			level	= CheckInput(level,'debug level',L.LEVELS);
			kLevel	= find(strcmp(level,L.LEVELS));
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
