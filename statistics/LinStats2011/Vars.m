classdef Vars
    % VARS a class for managing sets of variables
    %
    % VARS stores continuous and categorical variables in numerical format
    % usage.
    %   M = Vars( x1, ... )   % builds a set of Variables
    %   M = Vars( A1, ... );  % builds a homotypic collection of variables from
    %   each column of the As
    % 
    %   optional arguments 
    %     A,x         The data. For categorical variables x is in 1..k
    %                 for continous x is any matlab number
    %     type       Used to explicitily set the variable type (i.e. continuous/categorical)
    %                 The is one provided for each variable input. The ith type
    %                 applies to all columns of the ith input argument. 
    %                 Less or equal 0 is continuous. Default is
    %                 continuous for single and float and categorical for
    %                 integer and cellstr. x1 may also be a numeric matrix
    %                 to specify a homotypic dataset (all the same type)
    %                 The possible values are
    %                    4 means reference encoding (0/1) full rank
    %                    3 means coding 0/1, overdetermined, random
    %                    2 means coding 0/1, full rank (aka ordinal encoding)
    %                    1 means coding 0/-1/1, full rank (aka nominal encoding)
    %                    0 means continous. use predictor variable directly
    %                    -1 means continuous centered
    %                    -2 means continuous centered and scaled to range 2
    %                    (-1..1)
    %     anno     dataset or cellstr to annotate variables (e.g. name )
    %                 The ith row corresponds to the ith input variable. 
    %                 If input variables are a mix of homotypic matrices and individual factors
    %                 use a cell array of datasets (or cellstrs). 
    %                 The first column of the input array
    %                 will be used in displays. If there are multiple input
    %                 arguments the annotations must allow vertical
    %                 concatenation. You can provide a single annotation
    %                 for all input arguments or a cell array for separate
    %                 input homotypic input arguments. 
    %                 e.g. M = Vars(A1,A2, 'anno', { A1anno, A2anno } ); %
    %                 for homotypic input
    %                  or   M = Vars(x1,x2, 'anno', x1x2anno );  % for
    %                   individual input arguments
    %     levelnames    For each categorical variable a list of all possible
    %                 levels names and the ordering implies a specific
    %                 encoding. The default order is unique alphabetically
    %                 sorted levels that exist in the input variable mapped
    %                 to integers 1..k.
    %
    %   M = Vars( x1, A1, ... ); % syntax that allows all mixed types to be
    %   added at once. This is very similar to adding each variable
    %   separately
    %   M = addVar( addVar( Vars( x1,... ), A1, ... ), ... )
    %
    % Methods
    %    given that v = Vars(...)
    %    v.NAME, where NAME is a variable name to get
    %    use v(:,ci) or v(ri,:) to create a new Vars object with specified
    %    rows and columns
    %    use v.x(:,ci) or v.x(ri,:) to get just the numerically encoded data
    %    matrix
    %    use [v1 v2] or [v1;v2] to concatentate either new variables or new
    %    observations, respectively
    %
    % Example
    %   load weather
    %   x = Vars(g1,g2,g3);
    
    % Copyright 2011 Mike Boedigheimer
    % Amgen Inc.
    % Department of Computational Biology
    % mboedigh@amgen.com
    %
    properties(GetAccess='public', SetAccess='public')
        x           = zeros( 0, 0);    % numerically encoded data matrix
        % (m x n) with one column per variable
        level_names = cell(0,1);     % cellstr or n-cell array of
        % cellstrs of level names for
        % categorical variables
        anno  = dataset;         % anno
    end
    properties(GetAccess='public', SetAccess='public')
        type        = zeros( 1, 0);    % n-row vector of variable types
    end
    properties(Dependent=true)
        iscategorical;
    end
    methods
        function a = Vars(varargin)
            [args types lnames anno] = a.parseArgs( varargin{:} ); %#ok<*PROP>

            nargs    = length(args);
            if nargs == 1
                if isempty(anno)
                    anno = inputname(1);
                end
                a = addVar( a, args{1}, types, lnames, anno );
            else
                for i = 1:nargs
                    if isempty(anno{i});
                        anno{i} = inputname(i);
                    end
                    a = addVar(a, args{i}, types(i), lnames{i}, anno{i} );
                end
            end
        end
        
        function type = get.type( a )
            type = a.type;
        end
        function b = israndom(a)
            b = abs(a.type)==3;
        end
        function b = get.iscategorical(a)
            % returns a boolean vector indicating which variables in a are
            % categorical (nominal or ordinal)
            b = a.type>0;
            if size(a,2) > 1 && length(b) == 1
                b = repmat(a.type>0, 1, size(a,2));
            end
        end
        function b = iscontinuos(a)
            b = a.type<=0;
        end
        function b = isempty(a)
            b = isempty(a.x);
        end
        function a = cat(dim,varargin)
            %CAT Concatenate Vars arrays.
            %   V = CAT(DIM, V1, V2, ...) concatenates the Vars arrays V1, V2,
            %   ... along dimension DIM by calling the @Vars/HORZCAT or
            
            if dim == 1
                a = vertcat(varargin{:});
            elseif dim == 2
                a = horzcat(varargin{:});
            else
                error('LinStats:Vars:cat:InvalidDim', ...
                    'DIM must be 1 or 2 for a 2-D Vars array.');
            end
        end
        function a = addVar( a, f, type, lnames, var_name )
            %ADDVAR adds new homogenous variable or variables to a Vars object
            % addVar( a, f, type, lnames,  var_name )
            % if var_name is a single element and f is a matrix then
            % var_name is replicated and applied to all columns of f
            
            [nobs nvars] = size(a.x);       % current data size
            
            if ischar(f)        % support character arrays by converting to cell str. Do this before input variable size is calculated
                f = cellstr(f);
            end
            
            [fobs fvars] = size(f);         % variable size
            
            if fobs ~= nobs
                if nobs ~= 0
                    error('LinStats:Vars:InvalidArgument', 'factors must be a vector of length %d', nobs );
                end
            end;
            
            % set variable type
            if isempty(type) || isnan( type )
                if iscellstr(f) || isinteger(f) 
                    type = 1;
                else
                    type = 0;
                end
            end
            
            if length(type) > 1 && length(type) ~= fvars
                error('LinStats:Vars:InvalidArgument', 'TYPE vector  must be length %d', fvars);
            end
            
            if isempty( var_name )
                var_name = 'x';
                str = sprintf( '%s%%d\\n', var_name );
                var_name = strread( sprintf( str, nvars+1:nvars+fvars), '%s\n');
            end
            
            if islogical(f)
                f = f+0;
            end
            
            % encode variable into desired numeric type
            if type > 0 % categorical variables
                % Step 1 create a variable, x that is in 1..k+1, where k+1 is a
                % missing value
                fsz = size(f);
                % if f is not numeric, then make it numeric and in 1..k,
                % where k is the number of levels
                if ~isnumeric(f)
                    if isempty(lnames)
                        [lnames , ~, x] = unique(f);
                        if isempty(lnames{1})   % empty is treated as NaN, not a new level
                            lnames = lnames( 2:end);   % delete empty
                            x = x-1;
                            x(x==0) = nan;
                        end
                    else
                        %augment f with all possible levels so that
                        %unique function will have them all. later delete
                        %the extras
                        f = cat(1,f, lnames );
                        [b , ~, x] = unique( f );
                        nextra = length(lnames);
                        x(end-nextra+1:end) = [];
                        
                        % map observed level names to given level names
                        [c ci] = ismember( b, lnames);
                        if ~all(c)
                            error( 'variable contains unspecified levels');
                        end
                        % set the encoded values to be in the same order as
                        % in lnames
                        x = ci(x);
                    end
                    x = reshape(x,fsz);
                else % f is already integer
                    b = unique(f(~isnan(f(:))));
                    [~, x] = histc( f, b);
                    
                    if isempty(lnames)
                        % if numeric values were provided and being treated
                        % as categorical, then create level_names as a cell
                        % string using a minimal length that is still
                        % distinct and captures whether they were integer
                        % or flot
                        if isnumeric( b)
                            % if functionally integers were provided disp as int
                            if all( b == floor(b))
                                d = 0;
                            else
                                % if float was provided then use the number
                                % of digits that separates the closest
                                % values
                                d = ceil( lre( min(diff(b)), 0 ))+1;
                            end
                            fmt = sprintf( '%%0.%df\n', d );
                            lnames_tmp = textscan( sprintf( fmt, b), '%s\n' );
                            lnames = lnames_tmp{:};
                        else
                            lnames = b;
                        end
                    end
                end
                
            else % var_type is 0 (continuous)
                if iscellstr(f)
                    error( 'cellstr can not be encoded as continuous');
                end
                
                
                % center and scale the continuous variables for types less
                % than 0. (always center random [-3])
                if type < 0 && ischar(var_name)
                    mu      = grpstats(f);
                    f       = bsxfun( @minus, f, mu);
                    var_name = strcat( var_name, '-', sprintf( '%.2f', mu ) );
                    if  type == -2
                        r    = range(f)/2;
                        f    = f/r;
                        var_name = sprintf( '(%s)/%.2f',var_name, r );
                    end
                end
                x = f;
            end
            
            if  size(var_name,1) == 1 && fvars > 1
                var_name = repmat( var_name, fvars, 1 );
            end           
            if ischar(var_name)
                var_name = cellstr(var_name);
            end
            if iscellstr( var_name )
                vn = 'dispname';
                if ~isempty(a.anno)
                    vn = a.anno.Properties.VarNames{1};
                end
                var_name = dataset( {var_name, vn} );
            end

            a.anno = vertcat( a.anno, var_name );
            
            % Cat the new variable into existing Varset
            j = size(a.x,2)+1;
            if isempty(a.x)
                a.x = x;
            else
                a.x = horzcat(a.x, x );
            end
            a.type = horzcat( a.type, repmat( type, 1, fvars ));
            
            % set level names
            if ~isempty(a.level_names)
                % if level_names is a cellstr and is homogenous, skip
                if iscellstr(a.level_names)
                    if isequal( a.level_names, lnames )
                        return;
                    else
                        % not homogeneous
                        l = cat(2, repmat( {a.level_names},1,j-1), repmat( {lnames(:)}, 1, fvars));
                    end
                else
                    % a.level_names is a cell array
                    l = cat(2, a.level_names, repmat( {lnames(:)}, 1, fvars));
                end
            else
                % a.level_names is empty. lengthen it and
                % add the given level_names to these variables.
                if isempty( lnames )
                    % if lnames is also empty then return
                    return;
                end
                % if preceeding variables were not categorical, then level_names is
                % empty. otherwise, no need to replicate because this is a homogeneous
                % structure
                if nvars >= 1
                    l = repmat( {[]}, 1, nvars+fvars);
                    l(nvars+1:end) = repmat( {lnames(:)}, 1, fvars );
                else
                    l = lnames;
                end
            end
            % if l is single element, then it can be stored as a cellstr, otherwise it
            % is a cell array
            if length(l) == 1 && iscell( l{1} )
                l = l{1};
            end
            a.level_names = l;
            
        end
        function x = decode( v, i )
            % DECODE returns an unencoded version of the ith variable
            %
            %   if the variable is continuous this function returns it as
            %   it is store (i.e. possibly scaled, centered)
            %  
            %   if the numeric encoding is nan, then empty string is used
            if nargin < 2
                i = 1;
            end
            
            if ~isscalar(i)
                error('LinStats:Vars:decode:InvalidSubscript', ...
                    'index must be a scalar.');
            end
            
            if v.type(i) <= 0
                x = v.x(:,i);
            else
                l = getLevelNames(v,i);
                l{end+1,1} = '';
                ind = v.x(:,i);
                nlevels = length(l);
                ind(isnan(ind)) = nlevels;
                x = l(ind);
            end
        end
        function v = recode( v, i )
            % RECODE a variable to compress categorical labels (e.g. after deletion) and
            % recalculate scaled or centered variables
            if nargin < 2
                i = true( size(v,2),1);
            end
            if islogical(i)
                i = find(i);
            end

            jcat = v.iscategorical(i);
            for j = 1:length(jcat);
                if v.iscategorical(j) > 0
                    [x, ~, xj] = unique(v.x(:,j)); % sorts nan last 
                    ln = getLevelNames(v,j);
                    k = find(~isnan(x));
                    ln = ln(x(k));
                    k = xj > length(k);
                    xj(k) = nan;
                    v.x(:,j) = xj;
                    v = setLevelNames(v, ln,j );
                end
            end
            jcenter = v.type(i) < 0;
            x = v.x(:,jcenter);
            x = bsxfun( @minus, x, nanmean( x));
            v.x(:,jcenter) = x;
            
            jscaled = v.type(i) == -2;
            r = range(v.x(:,jscaled));
            v.x(:,jscaled) = bsxfun( @rdivide, v.x(:,jscaled), r./2 );
        end
        function disp( v )
            %DISP 
            %
            tbl = var2tbl( v );
            disp(tbl);
        end
        function tbl = var2tbl( v )
            iscat = v.iscategorical;
            n = size(v,2);
            a = cell( n, 1 );
            if any(~iscat)
                [a{~iscat}] = mat2vec(v.x(:,~iscat));
            end
            
            for i = find(iscat)
                a{i} = decode(v,i);
            end
            
            header = v.anno.(v.anno.Properties.VarNames{1});
            if isnumeric(header)
                header = num2str(header);
            end
            header = cellstr(header);
            tbl = table( header, a{:} );
        end
        function display(v)
            %DISPLAY Display Varset
            %   DISPLAY(X) is called for the object X when the semicolon is not used
            %   to terminate a statement.
            %
            maxr = 30;
            maxc = 8;
            [m n]= size(v);
            if (m > maxr || n > maxc) && ~isempty(v)
                disp('**** partial listing ***** ');
                s = substruct( '()', {(1:min(m,maxr))',(1:min(n,maxc))'} );
                v = subsref(v,s);
            end
            
            disp(v);
        end
        function e = end(a,b,c)
            % end internal function called by Matlab to evaluate
            % expressions such as x(1:end,:);
            if c~=2
                error( 'LinStats:Vars:InvalidIndex', 'Vars indices must be 2 dimensional');
            end
            e = size(a,b);
        end
        function levels = getLevelNames(a,i)
            % GETLEVELNAMES returns the level_names for the ith variable.
            %
            % usage
            %   levels = getLevelNames(a,i)
            %   a is a Vars object
            %   I is a scalar integer.
            %   LEVELS is a cellstr containing the level_names of the ith variable.
            %   or a cellstr containing the variable name if it is not a categorical variable (i.e.
            %   type <=0)
            %
            %   LEVELS = GETLEVELNAMES(a,v)
            %   V is a vector of more than one integer index
            %   or any length logical vector
            %   LEVELS is a cell array of cell strings.
            %
            %
            % NOTES
            %   use a logical vector (even a single element)
            %   to force the return to be of type cell array of cell strings (rather than cellstr)
            
            n = size(a.x,2);
            please_use_cellstr = true;
            if nargin > 1
                if islogical(i)
                    i = find(i);
                    please_use_cellstr = false;
                end
                if max(i) > n
                    error( 'LinStats:Vars:IndexOutOfRange', 'index exceed length of level_names');
                end
                if min(i) <= 0
                    error( 'LinStats:Vars:IndexOutOfRange', 'index must be greater than 0');
                end
            else
                i = 1:n;
            end
            p = length(i);
            
            
            levels = a.level_names;
            if iscellstr(levels) && ~isempty(levels)
                % level names is a cellstr for homogenous and homotypic data, so just
                % replicate level_names the desired number of times
                reps = 1;
                if nargin < 2
                    reps = n;
                elseif ~isscalar(i)
                    reps = p;
                end
                levels = repmat( {levels}, 1, reps );
            else
                if isempty(levels);
                    k = true(1,p);
                    levels = a.anno.(a.anno.Properties.VarNames{1})(i(k));
                else
                    % it is a cell array of
                    levels = levels(i);
                    k = cellfun(@isempty, levels);
                    if any(k)
                        % MJB changed levels{k} to levels(k) because it failed
                        % when k had more than one element. I don't know if
                        % the change caused unintended consequences
                        %                         levels{k} = a.anno.(a.anno.Properties.VarNames{1})(i(k));
                        names = a.anno.(a.anno.Properties.VarNames{1})(i(k));
                        levels(k) = num2cell(names);
                    end
                end
            end
            
            if please_use_cellstr
                if length(levels) == 1 && ~iscellstr(levels)
                    levels = levels{1};
                end
            end
        end
        function a = horzcat(varargin)
            %HORZCAT Horizontal concatenation for Vars arrays.
            %   V = HORZCAT(V1, V2, ...) horizontally concatenates the Vars arrays
            %   V1, V2, ... .  You may concatenate Vars arrays that have duplicate
            %   variable names, This will result in Var arrays with multiple variables
            %   of the same name.
            
            b = varargin{1};
            if isempty(b)
                a = varargin{2};
                return;
            end
            if ~isa(b,'Vars')
                error('LinStats:Vars:horzcat:InvalidInput', ...
                    'All input arguments must be Vars.');
            end
            a = b;
            for i = 2:nargin
                b = varargin{i};
                if ~isa(b,'Vars')
                    error('LinStats:Vars:horzcat:InvalidInput', ...
                        'All input arguments must be Varss.');
                elseif size(a.x,1) ~= size(b.x,1)
                    error('LinStats:Vars:horzcat:SizeMismatch', ...
                        'All Vars in the bracketed expression must have the same number of observations.');
                end
                
                % concatenate variable type vectors (if needed). 
                a.type = horzcat( a.type, b.type );
                
                %% level_names
                % can be either a cellstr or a cellarray of cellstrs
                if iscellstr(a.level_names) && iscellstr(b.level_names) && isequal( a.level_names, b.level_names)
                    % do nothing
                else
                    a.level_names = horzcat( expandLevelNames(a), expandLevelNames(b) );
                end
                
                % let dataset do the concatenating of the annotation
                a.anno = vertcat( a.anno, b.anno);
                
                % concatenate the data last
                a.x = horzcat(a.x, b.x);
            end
        end
        function a = reorderLevels( a, ci, i )
            %REORDERLEVELS reorders levels for a categorical variable
            %
            %usage
            %   a = reorderLevels( a, ci, i )
            %
            %   ci is a vector the same length as there are levels for the ith variable
            %   containing numbers from 1..k
            %   a new set of levelNames will be created as old_level_names{ci} and
            %
            %  a.level_names{i} will be in the new order
            %  a.x(:,i) will relect the new ordering 
            %
            %   TODO:
            %   a = reorderLevels( a, ci )
            %       change the ordering of all variables of a homotypic collection of
            %       variables
            
            old_names = getLevelNames(a,i);
            k = length(old_names);
            
            if length(ci) ~= k
                error( 'LinStats:Vars:InvalidArgument', 'reordering vector must have the same number of elements as there are levels');
            end
            
            if a.type(i) <=0
                error('LinStats:Vars:InvalidArgument', 'can not reencode continuous variables');
            end
            
            % new level names
            new_names = old_names(ci);
            if isequal( new_names, old_names)
                return;
            end
            
            % do the encoding
            x = a.x(:,i);
            k = x>0;
            xi(ci) = 1:length(ci);
            x(k) = xi( x(k) );
            a.x(:,i) = x;
            
            a = setLevelNames( a, new_names, i );
            
        end
        function e = expandLevelNames(a)
            e = a.level_names;
            if iscellstr( a.level_names )
                e = repmat( {a.level_names}, 1, size(a.x,2) );
            end
        end
        function b = ishomotypic( v )
            %ISHOMOTYPIC returns true if all variables are of the same type and, if
            %categorical, have the same set of level_names.
            b = false;
            n = size(v.x,2);
            
            if n == 1 || iscellstr(v.level_names)
                b = true;
            end
        end
        function b = get.anno(a)
            b = a.anno;
        end
        function v = setLevelNames( v, ln, i )
            % SETLEVELNAMES relabels  encoded variables so that existing levels
            % numbers, i in 1..k, are remapped to labels given in ln{i}.
            %
            %  ln is a cellstr of level names for the ith variable in v, call it x.
            %  if x(j)==k then x(j) is associated with ln{k}
            %
            
            if v.type(i) <= 0 && ~isempty(ln)
                error('level_names can not be set for a continuous variables');
            else
                p = length(ln);
                if p ~= length(unique(ln))
                    error('level names must be unique');
                end
                q = sum(~isnan(unique(v.x(:,i))));
                if p<q
                    error('must be at least %d level names for the %s variable', q, num2ord(i) );
                end
            end
            
            if isvector(ln)
                ln = ln(:);
            end
            
            if ishomotypic( v )  % homogenous variables
                if i == ':'  % sets first (and all) variables
                    v.level_names = ln;
                elseif ~isequal( v.level_names, ln )        % requires change from homogeneous
                    l = repmat( {v.level_names}, 1, size(v.x,2) );
                    l{i} = ln;
                    v.level_names = l;
                end
            else
                v.level_names{i} = ln;
            end
            
        end
        function a = setType( a, i, type )
            %SETTYPE sets the variable encoding type for the ith variable
            %
            % v is the scalar variable type in -3..5 (see Vars) for the ith though jth
            % variable.
            % The type can not be changed from categorical to continuous or the
            % reverse.
            
            %TODO: check that the variable type is valid and the change in type is
            %valid. Recode the varible if necessary.
            a.type(i) = type;
        end
        function varargout = size(a,varargin)
            %SIZE returns the size of a Var object
            %
            %  sz = size(a)  returns a 2 element vector of number of rows and columns
            %  nrows = size(a,1) returns the number of rows in a
            %  ncols = size(a,2) returns the number of columns in a
            %  [nrows ncols] = size(a) returns the number of rows in columns in a as
            %                  a pair of scalars
            [varargout{1:nargout} ] =  size(a.x,varargin{:}) ;
        end
        function [varargout] = subsref(a,s)
            switch s(1).type
                case '()'
                    field = [];
                    % '()' is a reference to a subset of obs/vars that returns a Vars
                    % Parenthesis indexing can only return a single thing.
                    if nargout > 1
                        error('LinStats:Vars:subsref:TooManyOutputs', ...
                            'Too many outputs.');
                        
                        % No cascaded subscripts are allowed to follow parenthesis indexing.
                    elseif ~isscalar(s)
                        error('LinStats:Vars:subsref:InvalidSubscriptExpr', ...
                            '() indexing must appear last in a Vars array index expression.');
                    elseif numel(s(1).subs) ~= ndims( a.x)
                        error('LinStats:Vars:subsref:NDSubscript', ...
                            'Vars array subscripts must be two-dimensional.');
                    elseif numel(s(1).subs) == 3
                        field = s(1).subs{3};
                    end
                    
                    % Translate observation (row) names into indices (leaves ':' alone)
                    ri = row2ind(a, s(1).subs{1});
                    
                    % Translate variable (column) names into indices (translates ':')
                    ci = col2ind(a, s(1).subs{2}, field);
                    
                    % Create the output Vars and move everything over, including the
                    % properties. The RHS subscripts may have picked out the same observation
                    % or variable more than once, have to make sure names are uniqued.
                    varargout{1} = subset( a, ri, ci );
                case '{}'
                    % '{i,j}' returns v(i,j) as a set of j cells, each containing a Vars
                    % object with i columns
                    % '.x{i,j} returns v.x(i,j) as a set of j cell arrays each containing a
                    % matrix of i columns
                    
                    % No cascaded subscripts are allowed to follow parenthesis indexing.
                    if ~isscalar(s)
                        error('LinStats:Vars:subsref:InvalidSubscriptExpr', ...
                            '() indexing must appear last in a Vars array index expression.');
                    end
                    
                    ri = row2ind(a, s(1).subs{1});
                    ci = col2ind(a, s(1).subs{2});
                    x          = subset(a, ri, ci );
                    vo     = mat2cell( x, size(x,1), ones(1,size(x,2)) );
                    [varargout(1:nargout)]  = vo(1:nargout);
                    
                case '.'
                    if length(s)==1
                        varargout{1} = a.(s(1).subs);
                    else
                        a = a.(s(1).subs);
                        [varargout{1:nargout}] = subsref( a, s(2:end));
                    end
            end
        end
        function i = row2ind( a, s )
            %
            m = size(a.x,1);
            if ischar(s) && numel(s)==1 && s == ':'
                i = (1:m)';
            elseif islogical(s) || isnumeric(s)
                i = s(:);
            else
                error('LinStats:Vars:subsasgn:NDSubscript': 'row index must be '':'', numeric or logical');
            end
        end
        function a = subset( a, ri, ci )
            a.type = a.type(ci);
            if ~isempty(a.level_names) && ~iscellstr(a.level_names)
                a.level_names = a.level_names(:,ci);
            end
            a.x = a.x(ri,ci);           % subset data
            a.anno   = a.anno( ci,: );  % always take all columns of annotation
        end
        function a = subsasgn(a,s,b)
            %SUBSASGN Subscripted assignment to a Vars array.
            %
            creating = isequal(a,[]);
            if creating
                a = Vars;
            end
            
            switch s(1).type
                case '()'
                    % '()' is assignment into a subset of obs/vars from another Vars.  No
                    % cascaded subscripts are allowed to follow this.
                    
                    if numel(s(1).subs) ~= ndims(a.x);
                        error('LinStats:Vars:subsasgn:NDSubscript', ...
                            'Vars array subscripts must be two-dimensional.');
                    elseif ~isscalar(s)
                        error('LinStats:Vars:subsasgn:InvalidSubscriptExpr', ...
                            '()-indexing must appear last in a Vars array index expression.');
                    end
                    
                    ri =  row2ind(a, s(1).subs{1});
                    ci =  col2ind(a, s(1).subs{2});
                    
                    % Syntax:  a(ri,:) = []
                    %          a(:,ci) = []
                    %          a(ri,ci) = [] is illegal
                    %
                    % Deletion of complete observations or entire variables.
                    if isempty(b)
                        % Delete observations across all variables
                        if isequal(s(1).subs{2},':')
                            a.x(ri,:) = [];
                            % Delete entire variables
                        elseif isequal(s(1).subs{1},':')
                            a.x(:,ci) = [];
                            a.anno(ci,:) = [];
                            if size(a.level_names,2) > 1 || size(a.x,2) == 0
                                a.level_names(ci) = [];
                            end
                            a.type(ci) = [];
                        else
                            error('stats:Vars:subsasgn:InvalidEmptyAssignment', ...
                                'At least one subscript must be '':'' for empty assignment.');
                        end
                        
                        % Syntax:  a(ri,ci) = b
                        %
                        % Assignment from a Vars.  This operation is supposed to replace or
                        % grow at the level of the _Vars_.  So no internal reshaping of
                        % variables is allowed -- we strictly enforce sizes. In other words, the
                        % existing Vars has a specific size/shape for each variable, and
                        % assignment at this level must respect that.
                    else
                        % There's no compelling reason to accept raw values with the '()'
                        % subscripting syntax:  with a single element, you can use '{}'
                        % subscripting to assign raw values, or with a single variable, you
                        % can use dot subscripting.  With multiple variables, you'd have to
                        % wrap them up either in a Vars, which we do accept above, or in
                        % something like a structure or cell array, and that's a bit arcane.
                        error('LinStats:Vars:subsasgn:InvalidRHS', ...
                            'Assignment not supported.');
                    end
                    
                    
                    
                case '.'
                    % Assignment to or into a variable.  Could be any sort of subscript
                    % following that, but row labels are inherited from the Vars.
                    
                    % Translate variable (column) name into an index.
                    switch s(1).subs
                        case 'x'
                            if length(s) == 1
                                if ~all(size(b) == size(a.x))
                                    error('LinStats:Vars:subsasgn:IllegalAssignment', ...
                                        'new data variable must be the same size as the existing var.');
                                end
                                a.x = b;
                            else
                                a.x = subsasgn( a.x, s(2:end), b );
                            end
                            return
                        case 'anno'
                            if length(s) == 1
                                if ~isa( b, 'dataset');
                                    error('annotation must be a dataset');
                                end
                                if size(b,1) ~= size(a.x,2)
                                    error( 'must be one row in annotation dataset for each column of x');
                                end
                                a.anno = b;
                            else
                                a.anno = subsasgn( a.anno, s(2:end), b );
                            end
                            return
                        case 'type'
                            if length(s) == 1
                                if length(b) ~= length(a.type)
                                    error('LinStatsVars:subsasgn:IllegalAssignment', ...
                                        'new type variable must be the same size as the existing var.');
                                end
                                a.type = b;
                            else
                                a.type = subsasgn( a.type, s(2:end), b );
                            end
                            return
                            
                        otherwise
                            error('LinStatsVars:subsasgn:nosuchproperty', ...
                                'no such property or property can not be subsasgn''d.');
                    end
                    
            end
        end
        function a = vertcat(varargin)
            %VERTCAT Vertical concatenation for Vars
            %   DS = VERTCAT(DS1, DS2, ...) vertically concatenates the Vars arrays
            %   DS1, DS2, ... .  Observation names, when present, must be unique across
            %   Varss.  VERTCAT fills in default observation names for the output when
            %   some of the inputs have names and some do not.
            %
            %   If variables are annotated the first user supplied column must be
            %   identical for all Var arrays (including ordering, since there is no
            %   enforcement that names be unique it is not possible to reorder them
            %   automatically). In addition, the encoding levels must be identical.
            %
            %
            %   See also Vars/CAT, Vars/HORZCAT.
            
            
            b = varargin{1};
            if ~isa(b,'Vars')
                error('LinStatsVars:vertcat:InvalidInput', ...
                    'All input arguments must be Vars.');
            end
            a = b;
            
            for i = 2:nargin
                b = varargin{i};
                if ~isa(b,'Vars')
                    error('LinStatsVars:vertcat:InvalidInput', ...
                        'All input arguments must be Vars.');
                elseif size(a.x,2) ~= size(b.x,2)
                    error('Vars:vertcat:SizeMismatch', ...
                        'All Vars must have the same number of variables.');
                end
                
                % if variables are annotated use the first column as sort of key
                % all the variables must be present in both sets and in the same order
                if size(a.anno,2) > 1 && size(b.anno,2) > 1
                    if ~isequal( a.anno(:,2), b.anno(:,2) )
                        error('LinStatsVars:vertcat:UnequalVarNames', ...
                            'All Varss in the bracketed expression have the same variable names and be in the same order.');
                    end
                end
                
                if ~isequal( a.type, b.type)
                    error('LinStats:Vars:vertcat:UnequalVariableTypes', ...
                        'All Vars must have the same variable type');
                end
                
                if ~isequal( a.level_names, b.level_names)
                    error('LinStats:Vars:vertcat:UnequalLevelNames', ...
                        'All Vars must have the same level names');
                end
                
                a.x = vertcat( a.x, b.x );
                
                
            end
            
        end
        function n = nlevels(a, i)
            % returns the number of levels in a categorical variable or 1
            % for continuous variables
            if nargin < 2
                n = ones( size(a.x,2), 1 );
                k = a.type > 0;
                if any(k)
                    n(k) = cellfun( @length, getLevelNames(a, k));
                end
            else
                % this is tricky because if i is a numeric index then the
                % oder is important, don't blindly treat it as boolean
                i = i(:);
                [i order] = ind2logical(i(:), size(a.x,2));
                iscat = a.type(:) > 0;
                k = iscat(i);
                n = ones(size(k));
                n(k) = cellfun( @length, getLevelNames(a, i&iscat) );
                n(order) = n;
            end
        end
        function vn = getVarName(a,i)
            % returns a cellstr of names for the ith variable. i may be
            % scalar or vector of scalar or logical indices. VarNames are
            % the first column of the Variable annotation dataset.
            vn = a.anno.(a.anno.Properties.VarNames{1});
            if nargin > 1
                vn = vn(i);
            end
            if isnumeric(vn)
                vn = cellstr(num2str(vn));
            elseif ischar(vn)
                vn = cellstr(vn);
            end
        end
        function i = col2ind(a, s, field, exact)
            % search for columns with given index or that match regular
            % expression
            % j = col2ind(a, 'x1');  % finds the string x1 anywhere
            % in the annotation table
            % i = col2ind(a, 'x1[var_name]') % finds the string x1
            % in the column of the annotation table called var_name, x1 can
            % not contain '[' character, 
            if nargin < 3
                field = [];
            end
            if nargin < 4
                exact = [];
            end
            m = size(a.x,2);
            if ischar(s)
                if numel(s)==1 && s == ':'
                    i = (1:m)';
                    return;
                end
                i = search(a.anno, s, field, exact );
            elseif iscellstr(s)
                i = search(a.anno, s, field, exact );
            else
                i = s(:);
            end
        end
    end
    methods(Access='protected')
       
    end
    methods(Static)
        function [vars types lnames anno] = parseArgs( varargin )
            % Extract parameter value pairs from input args, and apply
            % defaults
            
            args  = ArgParser( varargin{:} );
            types = value( args, 'type', [] );
            anno  = value( args, 'anno', [] );
            lnames = value( args, 'levelnames', [] );
            vars = args.args;
            nargs = length(vars);
            if nargs > 1        % force cell arrays for empty outputs
                ec = cell(nargs,1);
                if length(types)==1, types = repmat( types, nargs, 1 ); end;
                if isempty(types), types = nan(nargs,1); end;
                if isempty(anno) % use defaults
                    anno = ec; 
                elseif  isa(anno, 'dataset') || iscellstr(anno)               % if annotation is a cellstr or dataset. then split it 
                    vlen = cellfun( @(x)size(x,2), vars);
                    anno = mat2cell( anno, vlen );
                end
                if isempty(lnames), lnames = ec; end;
            end;
        end
    end
    methods(Static)
        
        function [x,lnames,i] = grp2ind( f, lnames )
            %GRP2IND converts grouping variables in integer indices
            %
            %function [gi,gn,i] = grp2ind( varargin )
            % varargin is a set of n mgrouping variables of length m. They can be
            % integer, char or cell arrays of strings.
            % gi is an m x n matrix of integer grouping varibles
            % gn is a n x 1 cell array of unique levels names for each grouping
            %    variable.
            % i is an index into A such that gn = A(i,:);
            %
            %Example
            %  load weather
            %  [fi, fn] = grp2ind( g1, g2, g3 );
            %  factors  = ind2grp( fi, fn{:} );   % and back
            %
            % see also grp2idx, ind2grp
            %
            
            if nargin < 2
                lnames = [];
            end
            
            if ischar(f)
                f = cellstr(f);
            end;
            if ~isnumeric(f)
                if isempty(lnames)
                    [lnames , ~, x] = unique(f);
                    if isempty(lnames{1})   % empty is treated as NaN, not a new level
                        lnames = lnames( 2:end);   % delete empty
                        x = x-1;
                        x(x==0) = nan;
                    end
                else
                    %augment f with all possible levels so that
                    %unique function will have them all. later delete
                    %the extras
                    f = cat(1,f, lnames );
                    [b , ~, x] = unique( f );
                    nextra = length(lnames);
                    x(end-nextra+1:end) = [];
                    
                    % map observed level names to given level names
                    [c ci] = ismember( b, lnames);
                    if ~all(c)
                        error( 'variable contains unspecified levels');
                    end
                    % set the encoded values to be in the same order as
                    % in lnames
                    x = ci(x);
                end
            else % f is already integer
                b = unique(f(~isnan(f(:))));
                [~, x] = histc( f, b);
                
                if isempty(lnames)
                    if isnumeric( b)
                        lnames = strread( sprintf( '%d\n', b), '%s\n' );
                    else
                        lnames = b;
                    end
                end
            end
        end
        
    end
    methods (Static)
        function obj = loadobj(S)
            % Constructs a Vars object
            % loadobj used when a superclass object is saved directly
            % Calls reload to assign property values retrived from struct
            % loadobj must be Static so it can be called without object
            if isstruct(S)
                obj = Vars(S.x, 'anno', S.anno);
            else
                obj = S;
            end
        end
    end
end % classdef



