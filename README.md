

## Bycatch estimation tool

This is an archive of the files used to develop the bycatch estimator. The tool is now available as an R package. Please go to 
https://ebabcock.github.io/BycatchEstimator/

to access the current R package. 

Files on this page may not be up to date. 

1.BycatchModelSpecification.r

2.BycatchModels.r

3.BycatchFunctions.r

4.PreliminarySetup.r

5.PrintDataSummary.rmd

6.PrintResults.rmd

To use the tool, give the names of your data files, and the desired settings in
1.BycatchModelSpecification.r, and then run 2.BycatchModels.r in its entirety.
You should not need to modify anything except in 1.BycatchModelSpecification.r. The files called examplelog.csv and exampleobs.csv are simulated data examples loosely based on the Gulf of Mexico reef fish longline fishery, which will work with the example. 

The file labeled A.ReadDataLL.r sets up the data for analysis from the actual reef longline observer and logbook data, not included due to privacy concerns. Finally, the file called ObserverFromLLSIM.r generates simulated observer data from Phil Goodyear's LLSIM data, not included here.   

See the User Guide for more information. 
