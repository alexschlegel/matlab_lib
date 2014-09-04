classdef ArgParser < handle
    % Class to parser for input arguments Matlab functions
    %
    % Input arguments may be switches, options (name/value pairs), or
    % required/optional arguments
    %
    % Key features include
    %       * switch/option removal from input list to allow remaining
    %       switches/optoins to be passed to subsequent functions
    %       * single value switches eliminates need to for two inputs to
    %       toggle yes/no input choices
    %       * parse-as-you-go increases flexibility
    %       * simplified access to optional arguments beyond the normal end
    %       of the input list.
    %       * easy to specify default values
    %       * easy input checking
    %       * parsed values available 'on the fly' and as a structure
    % 
    % USAGE
    %   NOTE: ArgParser always searches p.parsed first to look for
    %   switches and options. If you want to override what the user
    %   provides, or accept an input structure instead of the input list it
    %   is easy to do by setting p.parsed to the input structure, then
    %   calling standard ArgParser methods. 
    %   
    %
    %   p = ArgParser( varargin{:});
    %   [b e] = isSet(p, 'switch_name', default); 
    %           returns true if 'switch_name' is in the input list 
    %           returns false if '~switch_name' is in the input list
    %           if neither is found the value of default is returned
    %           if default is not provided false is returned
    %           Also returns e to indicate whether either switch_name or
    %           ~switch_name was found (as opposed to using a default)
    % 
    %   v = value(p, 'param_name', default); % returns value or default of
    %                                        % parameter
    %
    % p.parsed 
    %       returns a structure that contains the switches and options that
    %       have been requested along with the value assigned (may have
    %       been default values even if unspecified by the input list)
    %
    % [v e] = value( p, i, default, error_fn )           
    % the ith argument is returned. if it is empty the default is returned
    % i may be larger than length args. Also returns e, a boolean, to
    % indicate whether the value was explicitly in the input list
    % error_fn will check the final value (v) against @(v)error_fn(v)
    %
    %   x1 = p.args{i}; % ith remaining argument in the list.
    %
    % Copyright 2011 Mike Boedigheimer
    % Amgen Inc.
    % Department of Computational Biology
    % mboedigh@amgen.com
    %
   
properties ( GetAccess='public', SetAccess='protected');
    args;
    parsed;   
end
properties
    case_sensitive = false;
    regexp_match   = false;  
    search_fn = @(c,strs)strcmpi(c,strs); 
end

methods
    function a = ArgParser( varargin )
        a.args = varargin;
    end
    
%     function s = parse( a, usage )
%         % parses the args using the usage information and returns a
%         % structure with associated fields set based on the args
%         % removes all elements from the args
%         % usage is a structure containing 
%         % usage.switch; % cellstr (table) of optional binary switch names.
%         % usage.params; % a table (cellstr) of optional parameter names. 
%         %               % The table can have a second column of defaults
%         %               % the order is unimportant. 
%         % usage.vars ;  % a table containing names for other variables in
%         %               % the arglist after removing the switches and params.
%         %               % The order of variables is important. Any
%         %               % variables not matched with associated values
%         %               % in the arglist passed to the function are set to
%         %               % null. 
%         % a structure is returned with the values filled in and the
%         % Associated items from the args are removed
%         %               % the table can have extra column describing the
%         %               % switch, which will be listed with the 'help' switch
%         
%         for i = 1:length(usage.switch)
%             s.(usage.switch{i}) = isSet(a, useage.switch{i});
%         end
%         
%         pn  = usage.params;
%         def = [];
%         if ~isvector(pn)
%             def = usage.pn(:,2);
%             pn = pn(:,1);
%         else
%             pn = pn(:);
%         end
%             
%         for i = 1:length(usage.switch)
%             if isempty(pn)
%                 s.(pn{i}) = value(a, pn{i}, def );
%             else
%                 s.(pn{i}) = value(a, pn{i}, def{i} );
%             end
%         end        
%         %%TODO parse usage.vars
%     end
    
    function set.case_sensitive( a, v)
    % case_sensitive. Sets the case-sensitivity property of an ArgParser
    %   a value of false will allow case insensitive searchs of the command
    %   line allowing the user to type it in mixed case. However you should
    %   always be consistent in queries for switch and option names
    %   otherwise p.parsed will multiple references to the same input
    %   argument. 
        a.case_sensitive = v;
        a.search_fn  = [];
    end
        
    function set.regexp_match( a, v)
    % regexp_match. Sets the regexp search capabilities of an ArgParser
    %   a value of true will allow regular expression matches to be conducted. 
    %   These are dangerous because they could easily match the
    %   wrong input. This is provided because some programmers have allowed
    %   the same option to be refered by multiple variants of the same spelling. 
    %   Also note that not all regular expressions make legal variable names, so
    %   those are illegal. 
        a.regexp_match = v;
        a.search_fn = [];
    end
    
    function set.search_fn( a, fn)
        if nargin > 1 && ~isempty(fn)
            a.search_fn = fn;
            return;
        end
        if a.case_sensitive
            if a.regexp_match
                a.search_fn = @(c,strs) regexpfind(c,strs);
            else
                a.search_fn = @(c,strs) strcmp(c,strs);
            end
        else
            if a.regexp_match
                a.search_fn = @(c,strs) regexpifind(c,strs);
            else
                a.search_fn = @(c,strs) strcmpi(c,strs);
            end
        end
    end
    
    function parseStruct( a, s )
        fns = fieldnames(s);
        for i = 1:length(fns)
            fn = fns{i};
            a.parsed.(fn) = {s.(fn) true};
        end
    end
        
     function [b e] = isSet(a, switch_name,default )
        % looks for 'switch_name' (or '~switch_name') i input list and
        % returns non-zero (zero) value if found
        % here is a table to illustrate the possiblities, where switch_name
        % is 'sn'
        % b e switch default
        % 1 1 'sn'   0
        % 1 1 'sn'   1
        % 0 0 [],    0
        % 1 0 [],    1
        % 0 1 ~sn    0
        % 0 1 ~sn    1
        if isfield(a.parsed,switch_name)
            b = a.parsed.(switch_name); % two element cell array with value and binary indicator of whether it was found
            e = b{2};  % this that evaluates to true if switch_name was on the command line
            b = b{1};  % this evaluates to true if switch is on, but it can be anything if switch_name was actually an option
            % For options, isSet asks about wether the option was in the input list
            % command line. Therefore, if it is empty force it to evaluate
            % true. the only exception is if options are used for switches
            % (i.e. they are logical values)
            if ~islogical(b)
                b = e;
            end
        else
            b = find(a.search_fn( switch_name, a.args));
            if isempty(b)  % switch_name not found
                b = find(a.search_fn( ['~' switch_name], a.args));
                if isempty(b)  % ~switch_name not found - use default
                    if nargin < 3
                        default = false;
                    end
                    b = default ~= 0;   
                    e = false;
                else % ~switch_name found  - return false
                    a.args(b) = [];
                    b = false;
                    e = true;
                    
                end
            else  % switch_name found - return true
                a.args(b) = [];
                b = true;
                e = true;
            end
            a.parsed.(switch_name) = {b e};
        end
    end
       
    function [x found] = value( a, param_name, default, error_check)
        % returns the value associated with param_name, or default if it is
        % not set and a default value is provided. Otherwise returns (x = []). 
        % Removes associated elements from the args
        % if param_name is numeric it is treated as an index into args and
        % the ith argument is returned, or the default is returned if the
        % argument is empty or exceeds the length of args.
        % usage
        %    [x found] = value( a, param_name, default, error_check)
        if nargin<3
            default = [];
        end
        x = default;
        found = false;
        if isnumeric(param_name)
            i = param_name;
            if i <= length(a.args) && ~isempty( a.args{i} )
                x = a.args{i};
                found = true;
            end
        elseif isfield(a.parsed, param_name)
                x = a.parsed.(param_name); % x is two element cell array with value and binary indicator of whether it was found
                found = x{2}; 
                x = x{1};
        else
            b = find(a.search_fn(param_name, a.args));
            if ~isempty(b)
                x = a.args{b+1};
                a.args( [b b+1] ) = [];
                found = true;
            end
            a.parsed.(param_name) = {x found};
        end
        if nargin > 3
            if ~error_check(x)
                if ischar(param_name)
                    error( '%s failed error check', param_name );
                else
                    error( '%s input argument failed error check', num2ord(param_name) );
                end
            end
        end
    end
    
end
end