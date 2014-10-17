classdef Subject < PTB.Object
% PTB.Subject
% 
% Description:	use to prompt for and access subject information
% 
% Syntax:	sub = PTB.Subject(parent)
% 
% 			subfunctions:
% 				Start(<options>):	initialize the object
%				End:				end the object
%				Ask:				ask for subject info
%				Set:				set a subject attribute
%				Get:				get a subject attribute
%				Load:				load existing subject info
%				Save:				save subject info
%
% In:
%	parent	- the parent object
%	<options>:
%		load:			(-1) true to load existing subject info.  set to -1 to
%						prompt if subject info exists.
%		subject_info:	('basic') the type of subject info to collect.  can be:
%							{strName,strPrompt,[cChoice],[strClass]='char'}: a
%								four element cell specifying the name of a piece
%								of subject info (field name compatible), the
%								prompt to show when collecting the info,
%								optionally a cell of acceptable values (first one
%								is the default), and optionally the type of data
%								to store ('number', 'time', or a data type)
%							strPreset: the name of a preset piece of information.
%								one of:
%									init: initials
%									gender: gender
%									dob: date of birth
%									handedness: handedness
%									color_blind: is the subject colorblind?
%									eye_correction: does the subject have
%										correct vision?
%							strScheme: the name of a group of presets.  one of:
%								minimal: init
%								basic: init, gender, dob, handedness
%								full: everything
%						can also be a cell of the above.  defaults to 'minimal'
%						for debug mode.
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (Constant, SetAccess=private, GetAccess=private)
		p_preset	=	{
							'init'				, 'subject initials'					, []								, []
							'gender'			, 'subject gender'						, {'f','m'}							, []
							'dob'				, 'subject DOB'							, []								, 'time'
							'handedness'		, 'subject handedness'					, {'r','l','n'}						, []
							'color_blind'		, 'is subject colorblind?'				, {'n','y'}							, 'logical'
							'eye_correction'	, 'does subject wear eye correction?'	, {'none','glasses','contacts'}	, []
						};
		p_scheme	=	{
							'minimal'	, {'init'}
							'basic'		, {'init','gender','dob','handedness'}
							'full'		, {'init','gender','dob','handedness','color_blind','eye_correction'}
						};
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function sub = Subject(parent)
			sub	= sub@PTB.Object(parent,'subject');
		end
		%----------------------------------------------------------------------%
		function Start(sub,varargin)
		% initialize the subject object
			opt	= ParseArgs(varargin,...
					'load'			, -1	, ...
					'subject_info'	, []	  ...
					);
			
			
			sub.parent.Info.Set('subject','load',opt.load,'replace',false);
			
			if isempty(opt.subject_info)
				opt.subject_info	= conditional(sub.parent.Info.Get('experiment','debug')>0,'minimal','basic');
			end
			
			sub.Ask(opt.subject_info,'replace',false);
			sub.Save;
		end
		%----------------------------------------------------------------------%
		function End(sub,varargin)
			sub.Save;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
