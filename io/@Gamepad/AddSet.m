function obj = AddSet(obj,strName,set,varargin)

% AddSet
%
% Description: initialize a button set for isDown or pressed
%
% Syntax: obj = obj.AddSet(strName,set,exclusive) ***NOTE: you MUST add obj as
%               an output argument to update the object with 'set'
%
% In:
%       strName     -   the name of the set as a string
%       set         -   an Nx1 array of button code sets. Each row should 
%                       be a cell specifing a set of keys that will result 
%                       in a non-zero function return if pressed at 
%                       the same time.
%                       e.g. {{'A','B'}} = 'A' and 'B' pressed at the same 
%                       time. {{'A'};{'B'}} = either 'A' or 'B'.
%       exclusive   -   <false> true if the set should exclude all other 
%                       buttons (i.e. IsDown/Pressed will return true ONLY 
%                       if the specified buttons are down and NO others are 
%                       down. if other buttons are down/pressed they will 
%                       return errors)
% Out:
%       obj         -   the updated object with the set strName initialized 
%                       for use with isDown or pressed 
%
% Example: obj = AddSet('start',{'A','B'},true); - initializes the set 
% 'start' as simultaneous press (or press+release for 'pressed) of the 'A' 
% and 'B' buttons, isDown and pressed will return errors if any other 
% buttons are down/pressed when called
%
% ****NOTE****
% - You MUST call AddSet with the object as the output or else the object 
% will not be updated.
%
% Updated: 2011-12-05
% Scottie Alexander
% Alex Schlegel

% exclusive default is false
exclusive = ParseArgs(varargin,false);

strName = lower(strName);

if ~isempty(set)
    
    % put set into proper format (if it isn't already)
    [set,bK] = ForceCell(set,'level',2); 
    set = reshape(set,[],1);
    
    % get size of cell
    [nSets,w] = size(set);

    goodIndx = [];

    for j = 1:nSets % for each cell (i.e. set of buttons)
        [h,nKeys] = size(set{j,1}); 

        for k = 1:nKeys % for each of the buttons in the set

            btn = set{j,1}{1,k};

            % get button index
            if ischar(btn)
                kButton = obj.buttons(upper(btn));
            else
                kButton = btn;
            end

            % put button into array for good buttons
            kGood1(1,k) = kButton;
            goodIndx(1,end+1) = kButton; % single row array of all good buttons for kBad
        end
        kGood{j,1} = kGood1;
        clear('kGood1');
    end

    % get bad keys (if exclusive is true, all but kGood) 
    if exclusive
        kBad = setdiff(1:obj.buttons.n,goodIndx);
    else
        kBad = [];
    end
    
elseif isempty(set) && exclusive % set is 'NONE'
    kGood = [];
    kBad = 1:obj.buttons.n;
end

% add the button set to the btnSets struct
obj.btnSets(strName) = struct('good',{kGood},'bad',{kBad});

end