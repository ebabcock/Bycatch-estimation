#This file allows you to load multiple workspaces and compare the results. 
#This is mostly useful for comparing different variance estimates. 
#Alter the workspaces loaded and their names as needed

#Load multiple workspace and rename the predictions for combination
#load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputSimulated factor year sim big/R.workspace.rData")
#BigSim<-allmods[[1]]
load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputKept Reef LL delta var/R.workspace.rData")
Delta1<-allmods
summary(Delta)
load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputKept Reef LL sim var/R.workspace.rData")
Simvar1<-allmods
summary(Simvar)
load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputKept Reef LL no var/R.workspace.rData")
Novar1<-allmods
summary(Novar)

#Combine predictions
runnum<-1
run<-1
x<-list(DeltaMethod=Delta1[[runnum]],Simulated=Simvar1[[runnum]],Novar=Novar1[[runnum]])
summary(x)
allmods<-bind_rows(DeltaMethod=Delta1[[runnum]],Simulated=Simvar1[[runnum]],Novar=Novar1[[runnum]],.id="Type")
#allmods<-bind_rows(DeltaMethod=Delta,Simulated=Simvar,Novar=Novar,BigSim=BigSim,.id="Type")
allmods$Source=paste(allmods$Type,allmods$Source)
#Adjust numeric year if needed
#allmods$Year[allmods$Year<startYear]=allmods$Year[allmods$Year<startYear]+startYear
table(allmods$Source)
names(allmods)
summary(allmods)
#Plot combinations of models
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod NegBin","Simulated NegBin","Novar NegBin") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod NegBin","Simulated NegBin","DeltaMethod TMBnbinom2","Simulated TMBnbinom2","Novar TMBnbinom2","Novar NegBin") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod Tweedie","Simulated Tweedie","Novar Tweedie") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod Tweedie","Simulated Tweedie", "DeltaMethod TMBtweedie", "Simulated TMBtweedie","NovarTweedie","Novar TMBtweedie","Novar Tweedie") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod TMBnbinom1","Simulated TMBnbinom1","Novar TMBnbinom1") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod Gamma","Simulated Gamma","Novar Gamma") ),"All",NULL)

plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Delta-Lognormal","Novar Delta-Lognormal") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Delta-Gamma","Novar Delta-Gamma") ),"All",NULL)

plotSums(filter(allmods,Valid==1 & Source %in% c("DeltaMethod Lognormal","Simulated Lognormal","Novar Lognormal") ),"All",NULL)


## big is okay

plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated NegBin","BigSim NegBin") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated NegBin","Simulated TMBnbinom2","BigSim TMBnbinom2","BigSim NegBin") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Tweedie","BigSim Tweedie") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Tweedie", "Simulated TMBtweedie","BigSimTweedie","BigSim TMBtweedie","BigSim Tweedie") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated TMBnbinom1","BigSim TMBnbinom1") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Gamma","BigSim Gamma") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Lognormal","BigSim Lognormal") ),"All",NULL)

plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Delta-Lognormal","BigSim Delta-Lognormal") ),"All",NULL)
plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Delta-Gamma","BigSim Delta-Gamma") ),"All",NULL)



plotSums(filter(allmods,Valid==1 & Source %in% c("Simulated Tweedie","Novar Tweedie") ),"All",NULL)
write.csv(filter(allmods,Valid==1 & Source %in% c("DeltaMethod Tweedie","Simulated Tweedie", "DeltaMethod TMBtweedie", "Simulated TMBtweedie","NovarTweedie","Novar TMBtweedie","Novar Tweedie") ),"temp.csv")


## For LLSIM
#load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputLLSIMBUMtripOctobs75/R.workspace.rData")
ObsPlus<-allmods
#load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputLLSIMBUMtripOctpred75/R.workspace.rData")
AllPred<-allmods

## For kept reef finfish
#load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputKeptReefDelta/R.workspace.rData")
Delta<-allmods
#load("~/Box Sync/bycatch project (ebabcock@miami.edu)/Current R code/OutputKeptReefSimVar/R.workspace.rData")
SimVar<-allmods

trueVals$Total<-trueVals[,paste0("catch.",sp[run])]

#Combine predictions
runnum<-1
run<-1
#allmods<-bind_rows(ObsPlus=ObsPlus[[runnum]],AllPred=AllPred[[runnum]],.id="Type")
allmods<-bind_rows(Delta=Delta[[runnum]],SimVar=SimVar[[runnum]],.id="Type")
allmods$Source=paste(allmods$Type,allmods$Source)
table(allmods$Source)
names(allmods)

#Plot combinations of models
#runs<-c("AllPred","ObsPlus")
runs<-c("SimVar","Delta")

for(i in 2:length(modelTry)) {
 runType<-modelTry[i]
 modsToGet<-paste(rep(runs,each=length(runType)),rep(runType,length(runs)))
 #plotSums(filter(allmods,Valid==1 & Source %in% modsToGet ),"All",NULL)
 filenameval<-paste0("comparison","llkept",modelTry[i],".pdf")
 plotSumsValidate(filter(allmods,Valid==1 & Source %in% modsToGet ),trueVals,filenameval,"Total")
}
