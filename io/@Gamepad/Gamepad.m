classdef Gamepad
 
% Gamepad
%
% Description: the Gamepad constructor function. creates a gamepad object
%              for querying a gamepad device. NOTE: only supports
%              logitech_f310 and microsoft_sidewinder gamepads, the keyboard, or
%              the DBIC scanner button box.
%              
%
% Syntax: gp = Gamepad(type)
%
%         functions:  
%               IsDown
%               Pressed
%               State
%               AddSet
%
% In:
%       type    - the type of gamepad in a string. MUST one of the following:
%                    'logitech_f310'
%                    'microsoft_sidewinder'
%                    'keyboard'
%                    'button_box' (for the DBIC scanner)
%
% Out:    
%       gp      - a gamepad object
%
%                   Properties:
%                       type    -   a string of the type of gamepad
%                       buttons -   a object of class 'mapping' with
%                                   button-name / index pairs set up  
%                                   according to the specified gamepad type
%                       padID   -   {0} the ID number of the gamepad 
%                       btnSets -   named button sets for calling isDown or
%                                   pressed (enables multi button calls)
%                                   NOTE: can only be set with obj.AddSet
%
% Updated: 2011-11-25
% Scottie Alexander
 
%-------------------------------------------------------------------------%

    properties
       type 
       padID = 0;
    end
    
    properties
       buttons = mapping('mapindex',true);
       btnSets = mapping('mapindex',true);
       btnNums
    end
    
    properties (Hidden)
        notSets = struct;
        pressed = struct;
        f       = struct;
        param   = struct;
    end
    
%-------------------------------------------------------------------------%
    methods
        % the constructor function 
        function gp = Gamepad(type,varargin)
            persistent nGP;
            
            if isempty(nGP)
                nGP = 0;
            end
            nGP      = nGP + 1;
            gp.padID = nGP;
            
            if nargin > 0
                gp.type  = type;
                
                switch lower(type)
                    case {'logitech_f310','microsoft_sidewinder'}
                        gp.f.init	= @p_Init_Gamepad; 
                        gp.f.state	= @p_State_Gamepad;
                        gp.f.close	= @p_Close_Gamepad;
                    case 'keyboard'
                        gp.f.init	= @p_Init_Keyboard;
                        gp.f.state	= @p_State_Keyboard;
                        gp.f.close	= @p_Close_Keyboard;
                    case 'button_box'
                        gp.f.init	= @p_Init_ButtonBox;
                        gp.f.state	= @p_State_ButtonBox;
                        gp.f.close	= @p_Close_ButtonBox;
                    otherwise
                        error('Gamepad type must be "logitech_f310", "microsoft_sidewinder", "keyboard", or "button_box".');
                end
            else
                error('Please specify the type of game pad in a string (logitech_f310, microsoft_sidewinder, keyboard, or button_box)');
            end
            
            % initiate the gamepad
            	gp	= gp.f.init(gp,nGP,varargin{:});
            
            %get the buttons for this device
            	switch lower(gp.type)
					case 'logitech_f310'
						btns = {'X','A','B','Y','LB','LEFT','LUPPER','L','RB','RIGHT','RUPPER','R','LT','LLOWER','RT','RLOWER'};
						indx = {1,2,3,4,5,5,5,5,6,6,6,6,7,7,8,8};
					case 'microsoft_sidewinder'
						btns = {'A','B','X','Y','L','LEFT','R','RIGHT'};
						indx = {1,2,3,4,5,5,6,6};
					case 'keyboard'
						cKeys	= cellfun(@upper,KbName(1:255),'UniformOutput',false);
						bEmpty	= cellfun(@isempty,cKeys);
						
						indx	= num2cell(find(~bEmpty));
						
						[btns,kU]	= unique(cKeys(~bEmpty));
						indx		= indx(kU);
					case 'button_box'
						btns	= {'1','2','3','4','TRIGGER'};
						indx	= {49,50,51,52,53};
				end
				
				% map button names (btns) to their proper indices (indx)
				gp.buttons = mapping(btns,indx,'mapindex',true);
            
            % add built in sets
            gp = gp.AutoSets; 
        end
        
        function b = State(gp)
        	b	= gp.f.state(gp);
        end
        function b = Close(gp)
        	b	= gp.f.close(gp);
        end
    end
    
%-------------------------------------------------------------------------%

    methods
        
        % built in button codes
%previous code moved ^up there^ by 2011-09-12 by Alex.  This doesn't need to be
%calculated every time .buttons is accessed
         function buttons = get.buttons(obj)
         	buttons	= obj.buttons;
         end
         function obj = set.buttons(obj,val)
         	obj.buttons	= val;
         end
        
% % %         % map from button indicies back to button names
% % %         function btnNums = get.btnNums(obj)
% % %              switch lower(obj.type)
% % %                 case 'logitech_f310'
% % %                     btns = {'X','A','B','Y','LB','LEFT','LUPPER','L','RB','RIGHT','RUPPER','R','LT','LLOWER','RT','RLOWER'};
% % %                     indx = {1,2,3,4,5,5,5,5,6,6,6,6,7,7,8,8};
% % %                     
% % %                 case 'microsoft_sidewinder'
% % %                     btns = {'A','B','X','Y','L','LEFT','R','RIGHT'};
% % %                     indx = {1,2,3,4,5,5,6,6};
% % %             end
% % %             
% % %             % map button names (btns) to their proper indicies (indx)
% % %             btnNums = mapping(indx,btns);
% % %             
% % %         end
    end

end