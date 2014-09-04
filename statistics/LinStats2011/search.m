function i = search( ds, pat, field, reg_pat )
% search_dataset
% i = search( ds, pat, field, reg_pat )
% search dataset
%   ds is the dataset to search. 
%   pat is a number, logical, char or cell string to search with
%   field is optional. If present it is the name of a particular column
%   wihtin ds, otherwise all columns are searched
%   reg_pat turns on regular expression matching (case insensitive) instead
%   of the deafult strmcp (case sensitive)
%   if pat is a char it can contain the name of a column to search in
%   square brackets. e.g. pat[col], where pat is a string to search for and
%   'col', is the name of the column column to search. the field parameter
%   overrides this
%   
% 
% NOTE:
%   if searching unspecified columns (field is empty) with a numeric
%   pattern, it is the same as using ds(pat,:);
%
% Example
%   load weather
%   ds = dataset( g1,g2,g3,y);
%   k = search(ds, 1, 'g1' );   % searches column g1 for instances of 1
%   k = search(ds, 'hi' );  % ds(k,:) all have the word hi
%   k = search(ds,'hi', 'g2' ); % g2(k) has the word 'hi'
%   k = search(ds, 'hi[g2]' ); % g2(k) has the word 'hi'. only works with
%   limited set of regular expresssion searches.
%   k = search(ds,'[Hj]','g2',true ); % g2(k,:) has words containing H or
%   k = search(ds, 1 );   % same as ds(1,:);
%   j (case insensitive). 

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
if nargin < 4 || isempty(reg_pat)
    reg_pat = false;
end

if nargin < 3 || isempty(field) && ischar(pat)
    s = pat;
    pat = regexprep( s, '\[.*$','');
    field = regexptok( cellstr(s), '\[(\S+)\]$');
    if length(field)>=1
        field = field{:};
    end
end

% get the field name if specified
if ~isempty(field)
    if isnumeric( pat ) || islogical(pat)
        i = search_numeric( ds, pat, field );
    elseif iscellstr(pat) || ischar(pat)
        i = search_str(ds, pat, field, ~reg_pat );
    else
        error('pat must be numeric, logical, char or cellstr');  
    end
else %field is empty (search all columns)
    if isnumeric( pat ) || islogical(pat)
        i = pat;
    elseif iscellstr(pat) || ischar(pat)
        i = search_all_str( ds, pat, ~reg_pat  );
    else
        error('pat must be numeric, logical, char or cellstr');  
    end
end
end

function i = search_all_str( ds, pat, exact )
% find all variables in ds that are char or cellstr and search for pat.
% If using exact match use strcmp, otherwise use a regexpsearch
i = false(size(ds,1),1);
vn = ds.Properties.VarNames';
for j = 1:length(vn);
    f = ds.(vn{j});
    if ischar(f) || iscellstr(f)
        i = i | search_str(ds,pat,vn{j},exact);
    end
end
end

function i = search_str( ds, pat, field, exact )
% search ds.field for occurences of the string 'pat'
% if pat is a cellstr, search for any
f = ds.(field);
if ~ischar(f) && ~iscellstr(f)
    error('can not search a non-string field with a string pattern' );
end
if ischar(f)
    f = cellstr(f);
end
if nargin < 4 || exact
    fs = @(a,b) strcmp(a,b);
else
    fs = @(a,b) regexpifind(a,b);
end
if iscellstr(pat)
    i = false( size(ds,1),1);
    for j = 1:length(pat);
        i = i | fs(f, pat{j});
    end
else
    i = fs(f,pat);
end
end

function i = search_numeric( ds, pat, field )
f = ds.(field);
if isnumeric(f)
    i = ismember( f, pat );
end
end

