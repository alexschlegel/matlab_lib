classdef Model2 < Model
    % Model2 is a Model that is for two-way anova where the 
    % the response variable is a m x n array and the factors correspond to rows and columsn
    % useage
    % m = Model2( y );         % row_grps = 1:m, col_grps = 1:n
    % m = Model2( y, row_grp ); % use default col_grp
    % m = Model2( y, row_grp, col_grp );
    % m = Model2( y, [], col_grp ); %use deafult row_grp
    % m = Model2( y, {row_grp1, row_grp2}, ...);  % multiple groupings
    
    % Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
    
    %TODO: throw good error messages when sizes disagree
    %       change behavoir for empty row or column groups to leave that
    %       variable out of the model (i.e. treat it as replicates). 
    %       if neither are specified it is a null model with intercept only
    
    
    methods
        function a = Model2(y, varargin)
            % create X, v Vars object, representing the independent
            % variables
            
            ap   = ArgParser( varargin{:} );
            model = ap.value('model', 1);
            anno  = ap.value('anno', []);
            type  = ap.value('type', 1);  % default categorical
            
            [m n ] = size( y );
            % replicate r_grp n times
            r_grp = ap.value(1, 1:m);
            if iscell(r_grp) &&  ~iscellstr(r_grp)
                r_grp = cellfun( @(x) repmat( x, n, 1), r_grp, 'uniform', false );
            else
                r_grp = {repmat( r_grp(:), n, 1)};
            end
            
            c_grp = ap.value(1, 1:n);
            if iscell(c_grp) &&  ~iscellstr(c_grp)
                c_grp = cellfun( @(x) reshape( repmat( x,m, 1),numel(y),1), c_grp, 'uniform', false );
            else
                c_grp = {reshape( repmat( c_grp(:)', m, 1 ), numel(y), 1 )};
            end
            
            a = a@Model( y(:), r_grp{:}, c_grp{:}, ...
                'model', model, 'anno', anno, 'type', type);
        end
    end % methods
    
end % classdef



