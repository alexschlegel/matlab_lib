function tbl = dataset2table( x )
%DATASET2TABLE - converts a datset to a cellarray.
%
% usage
%  TBL = DATASET2TABLE( X ) returns TBL for the dataset X
%
% Example
%   load carbig
%     ds = dataset( MPG, Acceleration, Weight, Displacement );
%     tbl = dataset2table(ds);
%     % export('\mytable.tab', tbl );

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
v = x.Properties.VarNames';
n = length(v);
H = [];
D = cell(1,n);
j = 1;

for i = 1:n
    
    % build data
    t = x.(v{i});
    if ischar(t)
        t = cellstr(t);
    end
    p  = size(t,2);  % number of columns of the ith variable
    
    D{i} = t;
    
    % build header
    lh = repmat( {''}, p, 1); % header for these columns
    lh{1} = v{i};             % only the first one gets a name
    H = cat(1,H,lh);
end


tbl = table( H, D{:} );
    
    

    
    

