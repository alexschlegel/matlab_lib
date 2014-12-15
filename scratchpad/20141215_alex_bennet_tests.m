cd ~/temp/matlab_lib_scratch/scratchpad/
h = SigGen.show;
h = SigGen.show('iterations',1);
h = SigGen.show('iterations',1,'noisinessForDest',1e-6,'noisinessForSource',1e-6);
noise=0; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise);
noise=1e-6; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise);
noise=1000; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise);
noise=1000; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise,'recurStrength',noise);
noise=1; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise,'recurStrength',noise)
plot(mean(randn(100,10000),2))
figure; plot(mean(randn(100,1),2))
figure; plot(sum(randn(100,1),2))
figure; plot(sum(randn(100,10000),2))
noise=1; h = SigGen.show('iterations',1,'noisinessForDest',noise,'noisinessForSource',noise,'recurStrength',noise);
CausalSimulator.runDensityExample
noise=1; CausalSimulator.runDensityExample('noisinessForDest',noise,'noisinessForSource',noise);
noise=1; CausalSimulator.runDensityExample('noisinessForDest',noise,'noisinessForSource',noise,'pcaPolicy','runPCA');
noise=1; CausalSimulator.runDensityExample('noisinessForDest',noise,'noisinessForSource',noise,'pcaPolicy','runPCA','iterations',10);
WClassifier.runExample
noise=1; WClassifier.runExample('noisinessForDest',noise,'noisinessForSource',noise,'pcaPolicy','runPCA');