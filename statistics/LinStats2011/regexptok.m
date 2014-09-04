function [tokens unmatched] = regexptok( str, pat )
%REGEXPTOK. tokenize a (cell) string using regular expression patterns
%
%  USAGE
%       tokens = regexptok( str, pat);
%       [tokens unmateched] = regexptok( str, pat);
%
%      pat contains regular expression match using parens around the part of
%      pattern that matches each token. 
%  Must be the same number of matching tokens in all str (or no
%  matching tokens)
% 
% EXAMPLE
%  load carbig;
%   str = make_key( Model, Model_Year );  % create a string to use
%   (str separates model from year by a '_' character')
%  tokens = regexptok( str, '(.*)_(.*)' ); 
%  tokens(:,1); % contains Model
%  tokens(:,2); % contains Model_Year (as str)
%  cler Model;  % prevent interference with my class Model;


% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
    S  = regexp( str, pat, 'tokens' );
    k = cellfun( 'isempty', S );
    n = numel(S{1});
    S  = cat(1,S{~k});
    if isempty(S)
        tokens = repmat( {''}, size(k,1), n );
        unmatched = k;
        return;
    end    
    S  = cat(1,S {:}); 
    tokens = repmat( {''}, size(k,1), size(S,2) );
    tokens(~k,:) = S;
    
    unmatched = k;
end