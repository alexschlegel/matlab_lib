function [bButton,tCheck,bError,kDown] = IsDown(obj,setName)
% IsDown
%
% Description: query a gamepad to see if a button or set of buttons are
%              currently down.
%
% Syntax: [bButton,tCheck,bError,kDown] = obj.IsDown(setName)
%
% In:
%       setName   - the button/set to check as a string (MUST be a string)
%       exclusive - <false> if true, IsDown will return true ONLY if the
%                   specified button set is down and NO others
%
%       Button code: 
%           Both Logitech_f310 and Microsoft_sidewinder:   
%                    A        - right thumb "A" button 
%                    B        - right thumb "B" button 
%                    X        - right thumb "X" button 
%                    Y        - right thumb "Y" button 
%                    ANY      - check to see if ANY button is down
%                    NONE     - check for NO buttons down (bButton = true
%                               if NO buttons are down)
%
%           Logitech_f310 Only:
%                    LB (or LEFT or L)     - left-upper pointer finger button
%                    RB (or RIGHT or R)    - right-upper pointer finger button
%                    LT (or LLOWER)        - left-lower pointer finger button 
%                    RT (or RLOWER)        - right-lower pointer finger button
%                       
%           Microsoft_sidewinder Only:
%                    LEFT (or L)  - left pointer finger trigger
%                    RIGHT (or R) - right pointer finger trigger
% Out:
%       bButton - true if the target button is down and ~bError.  
%       tCheck  - the time at which the gamepad was queried
%       bError  - true if any bad btns were pressed (also if bError -> ~bButton)
%       kDown   - the indicies of any btns that were down
%
%
% Updated: 2011-09-13                    
% Scottie Alexander

% initialize some variables
bError = false;
bButton = true;
setName = lower(setName);

% get info on the button set
	curBtn = obj.btnSets(setName); % get current button struct
	
	% make sure that a supported button was called
	if isempty(curBtn)
	   error('This button is not supported, either initialize it as a button set with AddSet or type "help IsDown" to see built in buttons for each gamepad type.'); 
	end
	
	kButton = curBtn.good; % good buttons
	[nRows,nCols] = size(kButton); % get dims of good buttons
	kBad = curBtn.bad; % bad buttons

% get time of gamepad check
tCheck = GetSecs;

% query the device
	btns	= obj.f.state(obj);

kDown = find(btns);

% see if any bad buttons are down    
if any(btns(kBad))
    bError = true;
    bButton = false;

end

if ~bError
    % check each specified button set of setName (i.e. each row of kButton)
    for k = 1:nRows
        kSet = kButton{k,1}; % get button codes                       
        if all(btns(kSet)) % setName is down
            bButton = true;
            kDown = kSet;
            break;
        else
            bButton = false; % setName is not down
        end
    end
end

        
end