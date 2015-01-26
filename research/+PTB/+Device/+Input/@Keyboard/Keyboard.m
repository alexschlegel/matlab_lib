classdef Keyboard < PTB.Device.Input
% PTB.Device.Input.Keyboard
% 
% Description:	keyboard input device
% 
% Syntax:	key = PTB.Device.Input.Keyboard(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Down:				check to see if a key is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a key was pressed
%				State:				get the state of the keyboard
%				Get:				get the state indices associated with a named
%									button
%				Set:				set the state indices associated with a named
%									button
%				SetBase:			set the base state of the keyboard
%				key2char:			get the character of a key given its state
%									index
% 
% In:
%	parent	- the parent object
% 	<options>:
%		input_scheme:	('lr') the input scheme, to determine preset mappings.
%						one of the following:
%							lr:
%									left:	key_left
%									right:	key_right
%							lrud:
%									left:	key_left
%									right:	key_right
%									up:		key_up
%									down:	key_down
% Updated: 2014-09-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function key = Keyboard(parent)
			key	= key@PTB.Device.Input(parent,'keyboard');
			
			cKey	= cellfun(@(x) lower(x),KbName(1:255),'UniformOutput',false);
			kKey	= find(~cellfun(@isempty,cKey));
			cKey	= cellfun(@(x) str2fieldname(['key_' x]),cKey(kKey),'UniformOutput',false);
			
			[cKey,kUnique]	= unique(cKey);
			kKey			= kKey(kUnique);
			
			key.p_default_name	= cKey;
			key.p_default_index	= kKey;
			
			%get the arrow key names
				cArrowSuffix	= {'','arrow'};
				nArrowSuffix	= numel(cArrowSuffix);
				
				bSuffixFound	= false;
				for kA=1:nArrowSuffix
					strArrowSuffix	= cArrowSuffix{kA};
					strTest			= ['key_left' strArrowSuffix];
					
					if ismember(strTest,cKey)
						bSuffixFound	= true;
						break;
					end
				end
				
				if ~bSuffixFound
					error('Could not find the arrow keys!');
				end
			
			key.p_scheme			=	{
											'lr'	{
														{'left'		['key_left' strArrowSuffix]	[]}
														{'right'	['key_right' strArrowSuffix]	[]}
													}
											'lrud'	{
														{'left'		['key_left' strArrowSuffix]	[]}
														{'right'	['key_right' strArrowSuffix]	[]}
														{'up'		['key_up' strArrowSuffix]	[]}
														{'down'		['key_down' strArrowSuffix]	[]}
													}
										};
			key.p_scheme_default	= 'lr';
		end
		%----------------------------------------------------------------------%
		function Start(key,varargin)
		%Keyboard start function
			Start@PTB.Device.Input(key,varargin{:});
			
			%add some presets
				cKeyAll	= KbName(1:255);
				bKeep	= ~cellfun(@isempty,cKeyAll);
				cKeyAll	= lower(cKeyAll(bKeep));
				
				AddLRKey(key,cKeyAll,'shift');
				AddLRKey(key,cKeyAll,'control');
				AddLRKey(key,cKeyAll,'alt');
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		function AddLRKey(key,cKeyAll,strName)
			if ismember(strName,cKeyAll)
				cKeys	= {['key_' strName]};
			elseif ismember([strName '_l'],cKeyAll)
				cKeys	= {['key_' strName '_l'],['key_' strName '_r']};
			elseif ismember(['left_' strName],cKeyAll)
				cKeys	= {['key_left_' strName],['key_right_' strName]};
			elseif ismember(['left' strName],cKeyAll)
				cKeys	= {['key_left' strName],['key_right' strName]};
			else
				error(['No keys found for "' strName '"!']);
			end
			
			key.Set(strName,cKeys);
		end
	end
	%PRIVATE METHODS------------------------------------------------------------%
end
