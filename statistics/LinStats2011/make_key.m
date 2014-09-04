function [key gi gn] = make_key( varargin )
%MAKE_KEY - concatenate two vectors of numbers, chars or cell strings to
%produce a composite string optionally delimited by a specified character
%         
%
%
% usage
%  [key gi gn] = make_two_part_key( k1, k2, ...,  'delim', delim )
%       returns KEY, a cellstr containing a key formed by concatenating k1
%       and k2
%       K1, K2 ... KN are vectors or cellstrs
%       k1 may also be a vars object with any number of variables. (k2, ... kn are
%       not used)
%       gi and gi are returns from grp2ind
%
% see also grp2ind

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
arg = ArgParser(varargin{:});
delim = value( arg, 'delim', '_');

if isa( arg.value(1), 'Vars');
    v = arg.value(1);
    gi =  v.x ;
    gn = getLevelNames( v);
else
   [gi gn] = grp2ind( arg.args{:} );
end;

key =gn{1}(gi(:,1));
for i = 2:size(gi,2)
    key = strcat( key, delim, gn{i}(gi(:,i)));
end
