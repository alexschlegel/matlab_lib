function test_mixed_model_tests
%% PBIB 
[p fname ext] = fileparts( which('test_mixed_model_tests'));
pname  = [p, '\mixed_model_tests'] ;
addpath( pname );
load mixed_model_tests

try
s = Mstats(pbib1.glm);
H = [zeros(14,1) eye(14)];
result = htest(s, H );
compare_result(result, pbib1.result);

               
%% PBIB 2 
glm = pbib2.glm;
s = Mstats(glm);
H = [zeros(15,1) eye(15)];
result = htest( s, H );
compare_result(result, pbib2.result)


%% clinical 
glm = clinical.glm;
s = Mstats(glm);
H = [zeros(2,4) eye(2)];
result = htest( s, H );
compare_result(result, clinical.result)

disp('passed: mixed models');

catch ME
    disp( 'failed: mixed models');
end
end

function compare_result( a, b )

    fn = fieldnames(a);
    for i = 1:length(fn)
        if norm( a.(fn{i}) - b.(fn{i})) > 1e-6
            error( '%s failed mixed model tests', fn{i});
        end
    end
end