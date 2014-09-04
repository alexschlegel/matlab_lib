function test_model

%% fixed effects (3-way nominal)
try
    load weather
    v = Vars(g1,g2,g3, 'type', 1);
    m = Model(y,v,3);
    m = m.solve;
    r.fit = m.fit;
    r.anova = m.anova;
    r.estimates = m.estimates;
    r.expanded = m.expanded;
    r.means = m.means;
    r.predict = m.predict;
    
    s = load( 'test_model.mat');
    struct_compare( r, s.three_way_nominal_intercept);
    
    disp('passed: fixed effects model');
catch E
    disp('failed: fixed effects model' );
    disp( E.cause  );
end;


%% fixed effects (3-way nominal, no intercept)
try
load weather
model = Dmat.lmodel(3,3); model(1,:) = [];
v = Vars(g1,g2,g3, 'type', 1);
ws = warning('off','Model:NoIntercept');
m = Model(y,v,model);
warning(ws.state,'Model:NoIntercept');
m = m.solve;
r.fit = m.fit;
r.anova = m.anova;
r.estimates = m.estimates;
r.expanded = m.expanded;
r.means = m.means;
r.predict = m.predict;
    s = load( 'test_model.mat');
    struct_compare( r, s.three_way_nominal_nointercept);
    disp('passed: fixed effects model, no intercept');
catch E
    disp('failed: fixed effects model, no intercept' );
    disp( E.cause  );
end;

%% test analysis of covariance
% tests package functions using the carsmall example
% from mathworks; The results match JMP if care is taken to remove missing
% values before the model is created. To center a variable I use the mean
% of all the data, whereas JMP calculated the mean after variables have
% been removed. 
% functions tested are encode, mstats, anova sstype II
%   encode
%       encoding models for separate lines
%       encoding models for parallel lines
%       encoding models for same line, separate means and same mean
try
    load carsmall;
    clear Model;   % shadows my model class

    % model with separate slopes and intercepts
    % for each Model Year
    k = isnan(MPG);
    Model_Year(k) = [];
    Weight(k) = [];
    MPG(k) = [];
    v  = Vars( Model_Year, Weight, 'type', [1 -1] );
    m = Model(MPG,v,2);
    m = m.solve;
    r.fit = m.fit;
    r.anova = m.anova;
    r.estimates = m.estimates;
    r.expanded = m.expanded;
    r.means = m.means;
    r.predict = m.predict;
    
    s = load( 'test_model.mat');
    struct_compare( r, s.two_way_anacova   );
    disp('passed: 2-way anacova (separate lines)');
catch E
    disp('failed: 2-way anacova (separate lines)' );
    disp( E.cause);
end;


%% test polynomial (or at least continous model with crossed terms)
% this encodes fine. Not test of result because after encoding it is just a
% regular linear model
load carsmall;
clear Model;   % shadows my model class
k = isnan(MPG);
Model_Year(k) = [];
Weight(k) = [];
MPG(k) = [];
v  = Vars( Model_Year, Weight, 'type', [1 -1] );
m = Model( MPG, v(:,2), [0;1;2] );


%% test random continous variables
    load carsmall;
    clear Model;   % shadows my model class

    % model with separate slopes and intercepts
    % for each Model Year
    k = isnan(MPG);
    Model_Year(k) = [];
    Weight(k) = [];
    MPG(k) = [];
    v  = Vars(Weight,  Model_Year, 'type', [1 -3] );
    m = Model(MPG,v,2);

   
%% test multiple response variables
try
    load carsmall;
    clear Model;   % shadows my model class
    
    defaultStream = RandStream.getDefaultStream;
    defaultStream.reset;
    
    % model with separate slopes and intercepts
    % for each Model Year
    k = isnan(MPG);
    Model_Year(k) = [];
    Weight(k) = [];
    MPG(k) = [];
    v  = Vars( Model_Year, Weight, 'type', [1 -1] );
    y = [MPG bsxfun(@plus, MPG, randn( size(MPG,1),3)*.05 )];
    m = Model(y,v,2 );
    m = m.solve;
    r.fit = m.fit;
    r.anova = m.anova;
    r.estimates = m.estimates;
    r.expanded = m.expanded;
    r.means = m.means;
    r.predict = m.predict;
    s = load( 'test_model.mat');
    struct_compare( r, s.two_way_anacova_multiple_response );
    disp('passed: 2-way anacova (separate lines), multiple response');
catch E
    disp('failed: 2-way anacova (separate lines), multiple response' );
    disp( E.cause);
end;
%% mixed effects - balanced
try
load treatment

v = Vars(clinical.treatment, clinical.visit, clinical.sbj, 'type', [1 1 3], 'anno', {'treatment', 'visit', 'sbj'}');
model = [0 0 0; eye(3); 1 1 0];
m = Model(clinical.y,v,model);
m = m.solve;
r.fit = m.fit;
r.anova = m.anova;
r.estimates = m.estimates;
r.expanded = m.expanded;
r.means = m.means;
r.predict = m.predict;

    s = load( 'test_model.mat');
    struct_compare( r, s.mixed_effects_clinical  );
    disp('passed: mixed effects, clinical example');
catch E
    disp('failed: mixed effects, clinical example' );
    disp( E.cause);
end;

%% mixed effects - unbalanced

try
load treatment

v = Vars(clinical.treatment, clinical.visit, clinical.sbj, 'type', [1 1 3], 'anno', {'treatment', 'visit', 'sbj'}');
model = [0 0 0; eye(3); 1 1 0];
m = Model(clinical.y,v,model);
m.hidden = 1;
m = m.solve;
r.fit = m.fit;
r.anova = m.anova;
r.estimates = m.estimates;
r.expanded = m.expanded;
r.means = m.means;
r.predict = m.predict;

    s = load( 'test_model.mat');
    struct_compare( r, s.mixed_effects_clinical_unbalanced  );
    disp('passed: mixed effects, unbalanced clinical example');
catch E
    disp('failed: mixed effects, unbalanced clinical example' );
    disp( E.cause);
end;


%% hidden variables
% use carsmall that removes italy from model

%% missing variables
% 

%% singular models 

%% over determined  (more parameters than obs)


    