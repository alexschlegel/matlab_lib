function [bPress,tCheck,bError] = Pressed(obj,setName)

% Pressed
%
% Description: query a gamepad to see if a ful button press was executed
%              (i.e. button was up, then down, then up... thus it takes a 
%              minimm of three calls for this function to return true.
%
% Syntax: [bPress,tCheck,bError] = obj.Pressed(setName)
%
% In:
%       obj       - the gamepad object
%       setName   - the button set/code to check as a string - MUST be a string
%
%       Button code: 
%           Both Logitech and Microsoft:   
%                    A        - right thumb "A" button 
%                    B        - right thumb "B" button 
%                    X        - right thumb "X" button 
%                    Y        - right thumb "Y" button 
%                    ANY      - check to see if ANY button is down
%                    NONE     - check for NO buttons down (bButton = true
%                               if NO buttons are down)
%
%           Logitech Only:
%                    LB (or LEFT or L)     - left-upper pointer finger button
%                    RB (or RIGHT or R)    - right-upper pointer finger button
%                    LT (or LLOWER)        - left-lower pointer finger button 
%                    RT (or RLOWER)        - right-lower pointer finger button
%                       
%           Microsoft Only:
%                    LEFT (or L)  - left pointer finger trigger
%                    RIGHT (or R) - right pointer finger trigger
% Out:
%       bPress  - true if the target button was pressed since the last time that the device was queried 
%                 NOTE: if button = 'none' then bPress is true only if NO 
%                 buttons were pressed 
%       tCheck  - the time at which the gamepad was queried
%       bError  - true if any bad buttons were down when Pressed was called
%
%
% Updated: 2011-8-31                    
% Scottie Alexander

% set up the pressed struct
persistent bPressed

% has bPressed been initiated
if isempty(bPressed)
    bPressed = {};
end
if numel(bPressed)<obj.padID
    bPressed{obj.padID} = struct;
end
if ~isfield(bPressed{obj.padID},setName)
    % created a pressed struct to keep track of button state
    bPressed{obj.padID}.(setName) = struct('down',false,'wasDown',false,'wasUp',false,'bDown',[]);
end

% check gamepad
[bButton,tCheck,bError,kDown] = obj.IsDown(setName);

% is set down
if bButton
    bPressed{obj.padID}.(setName).down = true;
    bPressed{obj.padID}.(setName).bDown = kDown;
else
    bPressed{obj.padID}.(setName).down = false;
end

% set was down but is not down now
if bPressed{obj.padID}.(setName).wasDown && ~bButton  
    % are any btns down now that are part of setName
    if ~any(ismember(bPressed{obj.padID}.(setName).bDown,kDown))
        bNone = true; % no btns of setName are still down
        bPressed{obj.padID}.(setName).bDown = [];
    else
        bNone = false; % btns of setName are still down
    end
end

% update bPress and  state of the set
if bPressed{obj.padID}.(setName).down && ~bPressed{obj.padID}.(setName).wasDown && ~bPressed{obj.padID}.(setName).wasUp      % [1 0 0] is down when func is first called -> DN
    bPress = false;
elseif ~bPressed{obj.padID}.(setName).down && ~bPressed{obj.padID}.(setName).wasDown && ~bPressed{obj.padID}.(setName).wasUp % [0 0 0] not down, has not been down or recorded as up -> record as up
    bPressed{obj.padID}.(setName).wasUp = true;
    bPress = false;
elseif ~bPressed{obj.padID}.(setName).down && ~bPressed{obj.padID}.(setName).wasDown && bPressed{obj.padID}.(setName).wasUp  % [0 0 1] not down, has not been down, alread recorded as up -> DN (do nothing)
    bPress = false;
elseif bPressed{obj.padID}.(setName).down && ~bPressed{obj.padID}.(setName).wasDown && bPressed{obj.padID}.(setName).wasUp   % [1 0 1] is down, has not been down before, was recorded as up -> record as wasDown
    bPressed{obj.padID}.(setName).wasDown = true;
    bPress = false;
elseif bPressed{obj.padID}.(setName).down && bPressed{obj.padID}.(setName).wasDown && bPressed{obj.padID}.(setName).wasUp    % [1 1 1] is down, was down before, was up before -> DN (i.e. button is still down)
    bPress = false;
elseif  ~bPressed{obj.padID}.(setName).down && bPressed{obj.padID}.(setName).wasDown && bPressed{obj.padID}.(setName).wasUp && ~bNone
    bPress = false;
elseif ~bPressed{obj.padID}.(setName).down && bPressed{obj.padID}.(setName).wasDown && bPressed{obj.padID}.(setName).wasUp && bNone  % [0 1 1] button was pressed, then released -> reset wasDown/wasUp, return true
    [bPressed{obj.padID}.(setName).wasDown,bPressed{obj.padID}.(setName).wasUp] = deal(false);
    bPress = true;
end

% continue to return false if bError
if bError
    bPress = false;
end

end
