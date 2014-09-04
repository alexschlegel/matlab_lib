classdef Model
    % Model create framework for data modeling and analysis
    % It supports both fixed and mixed models with a common interface and
    % supports missing and hidden variables.
    % It also caches results of fitted models to avoid refitting
    %
    % usage
    %   M = Model(y)    builds a null model (intercept only)
    %   M = Model(y, V )    builds a main effects model with the variables in
    %                     V, a Vars Structure or numeric matrix
    %   M = Model( y, V,  model_spec ) creates a model matrix
    %                     combines the variables in X using the
    %                     specification in lm.
    %                     M can be scalar taken to mean a full-factorial
    %                     to a specified degree. For exaple means only
    %                     main effects, and 2 means also include 2-way
    %                     interactions, etc. .. Model_spec can also be an
    %                     matrix compatible with x2fx.
    %   M = Model(y, x1,x2,x3,..., xq,  'model', model_spec, ...);
    %        y and the model spec are used to specify the model, other input
    %        arguments are passed through to the Vars Constructor, so
    %        see the Vars help for more information on the available
    %        parameters
    %
    %
    % Example
    %       load weather
    %       M = Model(y, g1, g2, g3, 'type', 1, 'model', 2 );
    %       a = anova(M)  % don't use ';' at end of input to display output
    
% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%    
    properties(GetAccess='public', SetAccess='public')
        vars;
        y;
        model;
        missing;
        hidden;
        version = 1.0;
    end
    properties( GetAccess='public', SetAccess='protected');
        W;      %W is Augmented Design Matrix [X Z] for fixed and random effects
                  % I don't see how to support settting this since Model is
                  % based on Vars.  But, Dmat is set up to interact with W, ....
    end
    properties(GetAccess='private', SetAccess='protected')
        stats_;
    end
    
    properties(GetAccess='public', Dependent=true)
        stats;  % stats as dependent variable of stats_ is my way of doing lazy instantiation. 
    end
    
    properties(Dependent=true);
        ya;     % response variable(s) (analysis set)
        Wa;     % design matrix (analysis set)
        Xa;     % fixed effects  (analysis set)
        Za;     % random effects (analysis set)
        fi;     % index to fixed terms (i.e. X = Model.W(:,fi) );
        ri;     % index to random terms (i.e. Z = Model.W(:,ri) );
        X;      % full fixed effects design matrix (with missing and hidden values as nan)
        Z;      % full random effects design matrix (with missing and hidden values as nan)
        resid;      % get residuals from fitted curve (missing or hiddend values are returned as nan)
        yhat;   % get fitted curve(missing or hidden values are returned as nan)
        nobs;   % total number of observations in the model including hidden and missing
    end
    
    methods
        function a = Model(y, varargin)
            % create X, v Vars object, representing the independent
            % variables
            
            ap = ArgParser( varargin{:} );
            mmat = ap.value('model', 1 );
            X = ap.args{1};
            if isempty(X)
                X = Vars( ones(size(y,1),1), 'anno', 'intercept' );
                mmat = 0;  % model without intercept
            elseif ~isa(X,'Vars');  % but if we don't, ....
                % look for the param value pair 'model', a param is a
                % char with 1 row
                anno = ap.value('anno');
                if isempty(anno);
                    X = Vars( ap.args{:} );                    
                    anno = arrayfun( @inputname, 2:size(X,2)+1, 'uniformoutput', false )';
                    j = find(cellfun( @isempty, anno));
                    anno(j) = strenum( 'x', length(j));                
                    X.anno = dataset( {anno, 'varname'} );
                else
                    X = Vars( ap.args{:}, 'anno', anno );
                end
            else % Model(y, Vars )
                if length(ap.args) > 1 % Model(y,Vars,ModelMatrix)
                    mmat = ap.args{2};
                end
            end
            a.model = mmat;
            a.vars = X;
            if nargin >= 2 && ~isempty(y)
                a.y       = y;  % set.y also updates missing
            end
            a.hidden = [];
            if ~a.W.hasIntercept
                warning('Model:NoIntercept', 'Model has no intercept');
            end
        end
        
        function a = solve(a)
            % calculate status if necessary
            if isempty(a.stats_)
                if ismixed(a.W)
                    a.stats_ = Mstats(a);
                else
                    a.stats_ = Lstats(a);
                end
            end
        end
        
        function a = set.W(a,W)
            a.stats_ = []; %#ok<*MCSUP>
            a.W = W;
        end
        
        function glm = set.y(glm, y)
            glm.stats_ = [];
            nobs = glm.nobs;
            if size(y,1) ~= nobs && nobs ~= 0;
                error('the response variable must have the same length as the design matrix');
            end
            
            if isa(y,'HCData')||isa( y, 'Vars')
                y = y.x;
            end
            glm.y = y;
            ym = false(glm.nobs,1);
            ym(any(isnan(glm.y),2)) = true;
            if ~isempty(glm.vars)
                ym( any(isnan(glm.vars.x),2)) = true;
            end
            glm.missing = ym;
        end
        
        function a = set.vars(a, v)
            a.stats_ = [];
            % sets variables in the Model to v.
            % v must be compatible with the model spec (if present)
            if isempty(v) % this happens when objects are loaded from .mat files (I don't know why)
                return;
            end
            if ~isa(v,'Vars')
                error('v must be a vars object');
            end
            if ~isempty(a.y) && size(a.y,1) ~= size(v,1)
                error('the design matrix must have the same length as the response vector');
            end
            
            a.vars = v;
            ym = false(size(v,1),1);
            ym(any(isnan(a.y),2)) = true;
            ym( any(isnan(v.x),2)) = true;
            a.missing = ym;
            if ~isempty(a.model)
                m = a.model;
                a.model = m;        % updating model also has side effect of updating W
            end
        end
        
        function a = set.model( a, model)
            a.stats_ = [];
            % set s model. model may be a scalar until the vars are set,
            % then it is expanded into a full matrix representation
            p = size(a.vars,2);
            if p ~= 0;
                if isscalar(model)
                    % level model with no intercept and one independent
                    % variable as model = 0. (lmodel would return 1)
                    if model ~= 0 || p > 1
                        model = Dmat.lmodel( size(a.vars,2), model);
                    end
                end
                a.W = Dmat(a.vars,'model', model);
            end
            
            a.model = model;
        end
        
        function a = saveobj( a )
            
        end;
        
        function [X y k] = getAnalysisSet(a)
            k = a.missing | a.hidden;
            if any(k)
                j = ~k;
                y   = a.y(j,:);
                X   = a.W(j,:);
            else
                y = a.y;
                X = a.W;
            end
        end
        
        function s = get.stats(a)
            if isempty(a.stats_);
                a = solve(a);
            end
            s = a.stats_;
        end
        
        function ri = get.ri(a)
            ri = ~a.fi;
        end
        
        function fi = get.fi(a)
            fi = a.W.fi;
        end
        
        function W = get.Wa(a)
            % design matrix  (analysis set)
            k = a.missing | a.hidden;
            if any(k)
                W = a.W(~k,:);
            else
                W = a.W;
            end
        end
        
        function Z = get.Za(a)
            % design matrix for random effects (analysis set)
            k = a.missing | a.hidden;
            if any(k)
                Z = a.W.Z(~k,:);
            else
                Z = a.W.Z;
            end
        end
        
        function X = get.Xa(a)
            % design matrix for fixed effects (analysis set)
            k = a.missing | a.hidden;
            if any(k)
                X = a.W.X(~k,:);
            else
                X = a.W.X;
            end
        end
        
        function X = get.X(a)
            % design matrix for fixed effects (full set)
            X = a.W.X;
        end
        
        function Z = get.Z(a)
            % design matrix for fixed effects (full set)
            Z = a.W.Z;
        end
        
        
        function y = get.ya(a)
            k = a.missing | a.hidden;
            if any(k)
                y = a.y(~k,:);
            else
                y = a.y;
            end
        end
        
        function r = get.resid(a)
            s = a.stats;
            k = a.missing | a.hidden;
            r = nan(size(a.y));
            r(~k,:) = s.r;
        end
        
        function yhat = get.yhat(a)
            s = a.stats;
            k = a.missing | a.hidden;
            yhat = nan(size(a.y));
            yhat(~k,:) = s.yhat;
        end
        
        
        function n = get.nobs(a)
            n = 0;
            if ~isempty(a.y)
                n = size(a.y,1);
            end
            if ~isempty(a.vars)
                n = max(n, size(a.vars,1));
            end
            if  ~isempty(a.W)
                n = max(n, size(a.W,1) );
            end
        end
            
        
        function a = set.missing(a,k)
            if ~islogical(k)
                k = ind2logical( k(:), size(a.vars,1) );
            end
            if isequal(a.missing, k)
                return;
            end
            a.stats_ = [];
            if length(k) ~= a.nobs || ~islogical(k)
                error('linstats:Model:InvalidMissingFlag', 'missing flags must be a logical vector with length equal to the number of observations');
            end
            a.missing = k;
        end
        
        function a = set.hidden(a,k)
            % creates a new model after excluding observations in k. This can
            % change the  model itself. For example if all observations from a given
            % level are excluded then that the corersonding parameter will not be estimated
            m = size(a.vars,1);
            if  isempty(k)  % reset hidden variables
                k = false(m,1);
                if isempty(a.hidden)  % if k is empty and hidden is empty the are equal and we can prepare to return
                    a.hidden = k;   % initialize hidden from empty to false
                    return;         
                end
            elseif ~islogical(k)  % set the hidden variables by a numeric index
                k = ind2logical( k, m );
            elseif length(k) ~= m % hide variables using a logical flag
                error('linstats:Model:InvalidHiddenFlag', 'hidden flags must be a logical vector with length equal to the number of observations');
            end
            if isequal(a.hidden,k)
                return;
            end
            
            a.stats_ = [];
            a.hidden = k;
            if ~isempty( a.vars)
                v = a.vars;
                v.x(k,:) = nan;
                v = recode(v);
                a.W = Dmat( v, 'model', a.model );
            end;
        end
        
        function P = means(m)
            % least squares means of the groups
            %
            L = m.getlsestimator;
            m = m.solve;
            P = test( m.stats_, L );
            cn = P.cnames;
            cn{1} = 'grp means';
            P.cnames = cn;
            P.rnames = L.rnames;
            P.p = L.p;
        end
        
        function ls = expanded( a, varargin )
            %EXPANDED parameter estimates for a model.
            a = a.solve;
            s = a.stats_;
            ls = expanded(s,varargin{:});
            
        end
        
        function ls = contrast( a, varargin )
            % constrast (compare) parameter estimates of a given term.
            % Usage:
            %   P = contrast( ls, term, L )
            %   term is a scalar or vector refering to terms in the model
            %   if L is provided the columns refers to the expanded parameters for the terms being tested.
            %   each row of L will be a separate test.
            %
            a = a.solve;
            s = a.stats_;
            ls = contrast(s,varargin{:});
        end
        
        function L = getexestimator( glm )
            % GETEXESTIMATOR returns a linear combination of parameters
            % that produces expanded parameters estimates
            L = full(glm.W.emat(:));
        end
        
        function L = getlsestimator( glm )
            %GETLSESTIMATOR- returns L a linear combination of parameter estimates to produce
            %that produces the least squares estimators
            %
            % NOTES for ANACOVA models
            % The meaning of lsestimates is not very clear for ANACOVA
            % models, because the values of the continous variable changes
            % so does the ls estimates. In other words the average response changes depending
            % on the value of the continous variable, so which level should we adopt?
            %
            % See also
            %   lscontrast, lsestimates, getcontrasts
            %
            D = glm.W.X;            % design matrix for fixed terms only
            E = D.emat;             % matrix to expand estimates for each term
            M = glm.model(glm.fi,~(glm.vars.israndom));        % fixed terms only
            L = full(E); % this will be the linear combination
            vtype = glm.vars.type(~(glm.vars.israndom))>0;  % variable type (cat =true, cont=false);
            % for each term,t, in the model, corresponding to partitioned
            % rows of L
            
            dgr   = sum(logical(M),2);  % degree of term;
            has0 =dgr(1)==0;     % has intercept;
            if has0
                p = L.p(2:end);            % p is the number of levels of each factor
            else
                p = L.p;
            end;
            
            for t = 1:size(M,1)
                m = logical(M(t,:));           % variables included in this term
                ttype = all(vtype(m)>0);   % how to interpret term categorical = true, continous = false;
                
                if ttype &&  has0
                    L{t,1} = 1;
                end
                
                n = ones(1,length(m));
                n(m) = p(m);
                pind = ffact( n);           % columns correspond to variables in this term and rows the factor levels for the submatrix in L(t,:)
                % step through all terms and include all lower degree terms
                % that are included
                i = 1;
                while dgr(i) < dgr(t);
                    mt = logical(M(i,:)) & vtype == ttype; % variables to include
                    if any(mt) && ~any(~m&mt)   % must include at least one variable and must only contain variables in the term
                        % calculate the combination of factor levels for each
                        % row within this partion of L
                        nt = ones(1,length(m));
                        nt(mt) = p(mt);
                        qind    = ffact(nt);
                        [ignore, aj] = ismember( pind(:,mt), qind(:,mt), 'rows');
                        x        = double(E(i));
                        L{t,i} = x(aj,:);
                    end
                    i = i+1;
                end
            end
            
        end
        
        function a   = anova(glm, varargin)
            %ANOVA a type 3 anova (default) or type 1 for the linear model glm.
            %
            % usage:
            % a = anova(glm, type);
            % returns a, the anova results for each term in glm
            % type may be 1 or 3 for type I and type III sums of errors
            glm = solve(glm);
            a = anova(glm.stats_, varargin{:});
        end
        
        function a   = fit(glm)
            %ANOVA a type 3 anova for the linear model glm.
            %
            % usage:
            % a = anova(glm);
            % returns a, the anova results for each term in glm
            glm = solve(glm);
            a = glm.stats_.fit;
        end
        
        function [t full] = lof( glm )
            %LOF lack of fit statistics
            %
            %Example
            % t = lof( glm )
            % calculates lack of fit statistic, which is the amount of fit that is
            % unexplained by the model in glm, that is potentially explainable with a
            % different model with the same variables. Lack of fit is only calculable
            % if there are some observations with replicate measures.
            %
            % reduced is the least-squares solution to glm,
            % full is the least-squares solution to glm converted to a fixed effects
            % model with all variables treated as categorical.
            % TODO: does not work with mixed-model - add error or do it.
            
            reduced = glm.stats;
            
            % generate a new X that captures each unique set of predictor
            % variables in the model. %%TODO Not Validated
            X = double(glm.Wa);
            X = num2cell(X,1);
            X = make_key(X{:});
            
            full = Lstats(glm.ya, X, 'type', 1);
            
            t.dft   = reduced.dfe;
            t.dfe   = full.dfe;
            t.df    = t.dft - t.dfe;
            
            t.sst   = (reduced.sst - reduced.ssr); % = reduced.sse;
            t.sse   = full.sst - full.ssr;
            t.ss    = t.sst - t.sse;
            
            t.mss = t.ss./t.df;
            t.mse = t.sse./t.dfe;
            
            
            % can't calculate lof
            if ( t.df == 0 )
                t.pval = 1;
                t.ftest = nan;
            else
                t.ftest = t.mss./t.mse;
                t.pval = 1 - fcdf(t.ftest, t.df, t.dfe );
            end;
            
            t.source = {'lack of fit' };
            
            d = [t.mss; t.mse; t.ftest; t.pval];
            d = reshape( d, [1 4, size(t.mss,2)] );
            t = Pmat( d , [], [], {'pure error'}, {'mss', 'mse', 'f', 'Prob>f'}' );
        end
       
        function bhat = estimates(glm)
            %ESTIMATES estimates parameter values. Fixed model uses
            %least-squares and mixed model uses BLUE/BLUP
            %
            glm = solve(glm);
            bhat = glm.stats_.test;
        end
        
        function yhat = predict(a, X)
            % X is a Design matrix compatible with the Model.
            % if X is not provided 'predictions' are made on the
            % analysis set
            if nargin < 2
                X = a.W;
            end
            a = solve(a);
            b = double(a.stats_.beta);
            b = squeeze(permute(b,[1 3 2]));
            yhat = double(X)*b;
        end
       
        function str = display(a)
            if ismixed(a.W)
                str = 'linear mixed effects model with %d obs analyzed (%d missing, %d hidden, %d total)';
            else
                str = 'linear fixed effects model with %d obs analyzed (%d missing, %d hidden, %d total)';
            end
            
            str = sprintf( str, sum(~a.missing & ~a.hidden), sum(a.missing), sum(a.hidden), size(a.y,1));
            disp(str);
            ri  = ~a.W.fi;
            r = {'', '&Rnd' }';
            t = {'cont', 'nom', 'ord'}';
            type = a.W.type;
            type(type<0) = 0;
            type(type>2) = 1;
            t = t(type+1);
            % get the number of levels (for categorical or crossed)
            % and mean for each continuous factor
            str = table( {'no.', 'type', 'name', 'levels'}, ...
                (1:length(ri))', ...
                strcat(t, r(ri+1)), ...
                a.W.tnames, a.W.Le.p);
            
            disp(str);
        end
        
        function [h u] = plot(glm, vars, varargin)
            %PLOT interaction plot
            %
            % interaction plot
            % plots the lsmeans estimates for the given interaction vars in the model
            % along with 95% ls confidence intervals. lsmeans are the estimated
            % response at each particular combination of factor levels.
            % Interaction plots are intended to show graphically whether
            % there is a signficiant interaction between the factors in a fixed effects
            % model. If there is an interaction, it can make interpretting the primary
            % effects difficult. Also keep in mind that interpretting lsmeans in a
            % model with continuous variables is complicated: at which level of the
            % continous variable should the mean response be estimated?
            %
            % Example
            %      load popcorn
            %      m = Model( y, cols, rows, 'model', 2, 'type', 1 ); % build linear model
            %      plot(m, 1:2, 'stagger', 'legend'); % plot response verus cols colored by rows
            %
            % Example 2
            %      % continued from above
            %      plot(m, [2 1]); % plot response versus rows colored by cols
            %
            % See also lsestimates, encode, mstats, ciplot
            
            % TODO: this doesn't work with hidden variables and maybe not
            % with missing variables
            % take the code from set.hidden and apply it here to build a
            % recoded set of variables. Also use the analysis set instead
            % of the fullset for all plots. Make a note in the help that
            % the analysis is reconducted if it has not already been done
            % with the analysis set.
            %
            
            h = [];
            u = [];
            if nargin < 2 || isempty(vars);
                vars = 1;
            end;
            
            if length(vars)>4
                error('linstats:iplot:InvalidArgument', 'only supports up to 4 way interactions');
            end;
            

            newplot;  %supports hold on/off etc
            
            p = ArgParser(varargin{:});
            isLeg    = isSet(p, 'legend');
            response = value(p, 'response', 1);
            stagger  = isSet(p, 'stagger');
            isScatter  = isSet(p, 'scatter');
            plotSE     = isSet(p,'se');
            
            
            %TODO add range check to vars
            M = glm.model(glm.fi,:);
            
            % find the interaction term of interest
            if any(vars ) > size(M,2)
                error('linstats:Model.plot:InvalidArgument', 'the requested variable(s) is(are) not in the model');
            end
            term = find(all(M(:,vars)==1,2) & sum(M,2) == length(vars) );
            if isempty(term)
                error('linstats:Model.plot:InvalidArgument', 'the specified term(s) is(are) not included in the model, or are not fixed effects');
            end;
            glm.y = glm.y(:,response);
            ls    = means( glm );
            ls = ls{term,:};
            
            [vsort order] = sort(vars);     % TODO: use glm.W.emat to get current information on variable names and glm.W to get type
            ln = getLevelNames( glm.vars, vsort );
            var_type = glm.vars.type(vsort);
            
%             if isempty(stagger)
%                 stagger = var_type(1) > 0 && any(var_type(2:end)>0);
%             end
            
            if iscellstr(ln)
                ln = {ln};
            end
            xx = ffact(glm.vars.nlevels(vsort)); % xx has one column for each variable (not in requested order)
            gn = ind2grp( xx, ln{:} );
            vn = glm.vars.getVarName(vars);  % var names in requested order
            ln(order) = ln; % level names for each term (in requested order)
            gn(order) = gn; % level names for each parameter in the interaction term (in requested order)
            % put xx in requested order
            xx(:,order) = xx;
            
            sh = [];
            state = get(gca,'nextplot');
            set(gca,'nextplot', 'add')
            
            % plot the raw data (if requested)
            if isScatter
                y = glm.y;
                x = glm.vars.x(:,vars(1));
                x = jitter(x, .25, 'stem', y, 'nbins', 5 );
                %                 x = jitter(x, .01 );
                X = num2cell( glm.vars.x(:,vars), 1 );
                if size(X,2) > 1
                    [h u] = grpplot( x, y, X{2:end} );
                    % add legend labels
                    color_themes(h, u{1});
                else
                    [h u] = grpplot(x,y);
                end
            end
            
            hold on; 
            
            ci = ls(:,3);
            yl = 'average \pm ci';
            if plotSE
                ci = ls(:,2);
                yl = 'average \pm se';
            end
            if stagger
                v = Vars( gn{2}, 'levelnames', ln{2} );
                xxx = jitter( xx(:,1), .7, 'stagger', v.x(:,1), p.args{:} );
                [h lh] = grperrorbar( xxx, double(ls(:,1)), ci, gn{2:end} );
            else
                 [h lh] = grperrorbar( xx(:,1), double(ls(:,1)), ci, gn{2:end} );
            end
            set(gca,'nextplot', state);
            set( gca, 'xtick', 1:length(ln{1}), 'xticklabel', ln{1} );
            xlabel( vn(1) );
            
            ylabel(yl, 'interpreter', 'tex');
            
            % add legend labels
            for i = 1:length(lh)
                if ~isempty(lh)
                    if length(lh)>1
                        grp_themes(1, 'color',[]);
                        grp_themes(2, 'marker',[]);
                    else
                        grp_themes(1,'color', [], 'marker', []);
                    end
                end
            end
            
            if length(vars) > 1 && isLeg
                lh = grp_legend();
            end
            
            if nargout > 0
                lsq = ls;
            end;
            
        end
    end
    
    methods(Static)
        function a = loadobj(a)
            if isa(a,'struct')
                tmp = Model( a.vars, a.y, a.model);
                tmp.hidden = a.hidden;
                tmp.missing = a.missing;
                a = tmp;
            end
            a.version = 1.0;
        end
    end
    
end % classdef



