#This sets global conditions and makes a preliminary data summary

source("3.BycatchFunctions.r")

#Set global conditions
theme_set(theme_bw())
defaultW <- 0
options(warn=defaultW)
#options(warn = -1) 
mytheme <- gridExtra::ttheme_default(
  core = list(fg_params=list(cex = .8)),
  colhead = list(fg_params=list(cex = .8)),
  rowhead = list(fg_params=list(cex = .8)))
nSims<-1000  #For simulating CIs where needed
NumCores<-detectCores()

# Set up variables
obsdat<-obsdat %>%   ungroup() %>%
  rename(Year=!!yearVar)
logdat<-logdat %>%  ungroup() %>%
  rename(Year=!!yearVar)
requiredVarNames<-as.vector(getAllTerms(simpleModel))
allVarNames<-as.vector(getAllTerms(complexModel))  
allVarNames<-allVarNames[grep(":",allVarNames,invert=TRUE)]
if(!all(allVarNames %in% names(obsdat))) 
  print(paste0("Variable ", allVarNames[!allVarNames%in% names(obsdat) ], " not found in observer data"))
if(!all(allVarNames %in% names(logdat))) 
  print(paste0("Variable ", allVarNames[!allVarNames%in% names(logdat) ], " not found in logbook data"))
#It's all right not to see the variable name if it is a function of another variable that is present
indexVarNames<-as.vector(getAllTerms(indexModel))
if(!"Year" %in% indexVarNames) indexVarNames<-c("Year",indexVarNames)

#Set up data frames
#UnObsEffort=!!obsEffortNotSampled
obsdat<-obsdat %>%  
  rename(Effort=!!obsEffort) %>%
  mutate_at(vars(all_of(factorNames)),factor) 
if(EstimateBycatch) {
 if(is.na(logNum))   { 
   logdat<-mutate(logdat,SampleUnits=1)
   logNum="SampleUnits"
 }
 logdat<-logdat %>%  
   rename(Effort=!!logEffort,SampleUnits=!!logNum) %>%
  mutate_at(vars(all_of(factorNames)),factor) 
 if(logEffort==sampleUnit) logdat<-mutate(logdat,Effort=SampleUnits)
}

#newDat for making index
newDat<-distinct_at(obsdat,vars(all_of(indexVarNames)),.keep_all=TRUE) %>%
 arrange(Year) %>%
 mutate(Effort=1)
temp<-allVarNames[allVarNames != "Year"]
for(i in 1:length(temp)) {
  if(!temp[i] %in% indexVarNames) {
   if(is.numeric(pull(obsdat,!!temp[i])))
    newDat[,temp[i]]<-median(pull(obsdat,!!temp[i]),na.rm=TRUE) else
    newDat[,temp[i]]<-mostfreqfunc(obsdat[,temp[i]]) 
   } 
  }
#Set up directory for output
setwd(baseDir)
numSp<-length(sp)
if(!dir.exists(paste0("Output",runName))) dir.create(paste0("Output",runName))
outDir<-paste0(baseDir,"/output",runName)

#Make lists to keep output, which will also be output as .pdf and .csv files for use in reports.
dirname<-list()
dat<-list()
#Loop through all species and print data summary. Note that records with NA in either catch or effort are excluded automatically
yearSum<-list()
fileList<-NULL
if(NumCores>3 & numSp>1)  {
  cl<-makeCluster(NumCores-2)
  registerDoParallel(cl)
}
foreach(run= 1:numSp) %do%  {
  dirname[[run]]<-paste0(outDir,"/",common[run]," ",catchType[run],"/")
  if(!dir.exists(dirname[[run]])) dir.create(dirname[[run]])
  dat[[run]]<-obsdat %>%
    rename(Catch=!!obsCatch[run])%>%
    dplyr::select_at(all_of(c(allVarNames,"Effort","Catch"))) %>%
    drop_na()   %>%
    mutate(cpue=Catch/Effort,
           log.cpue=log(Catch/Effort),
           pres=ifelse(cpue>0,1,0)) 
  if(dim(dat[[run]])[1]<dim(obsdat)[1]) print(paste0("Removed ",dim(obsdat)[1]-dim(dat[[run]])[1]," rows with NA values for ",common[run]))
  yearSum[[run]]<-dat[[run]] %>% group_by(Year) %>%
    summarize(ObsCat=sum(Catch,na.rm=TRUE),
              ObsEff=sum(Effort,na.rm=TRUE),
              ObsUnits=length(Year),
              CPUE=mean(cpue,na.rm=TRUE),
              CPUEse=standard.error(cpue),
              Outlr=outlierCountFunc(cpue),
              Pos=sum(pres,na.rm=TRUE)) %>%
    mutate(PosFrac=Pos/ObsUnits)
  if(EstimateBycatch) {
   x<-logdat  %>% group_by(Year) %>%
    summarize(Effort=sum(Effort,na.rm=TRUE),Units=sum(SampleUnits)) 
   yearSum[[run]]<-merge(yearSum[[run]],x) %>% mutate(EffObsFrac=ObsEff/Effort,
                                                     UnitsObsFrac=ObsUnits/Units)
   logyear<-logdat %>% group_by(Year) %>% summarize(Effort=sum(Effort,na.rm=TRUE))
   x=ratio.func(dat[[run]]$Effort,dat[[run]]$Catch,dat[[run]]$Year,
               logyear$Effort,logyear$Effort,logyear$Year)
   yearSum[[run]]<-cbind(yearSum[[run]],CatEst=x$stratum.est,Catse=x$stratum.se) %>% 
    ungroup() %>% mutate(Year=as.numeric(as.character(Year))) %>%
    dplyr::rename(!!paste0("Obs",sampleUnit):=ObsUnits,                                 ,
                  !!sampleUnit:=Units,
                  !!paste0(sampleUnit,"ObsFrac"):=UnitsObsFrac)
  } 
  write.csv(yearSum[[run]],paste0(dirname[[run]],common[run],catchType[run],"DataSummary.csv"))
  printTableFunc("Data summary",sp[run],yearSum[[run]],paste0(dirname[[run]],common[run],catchType[run],"DataSummary.pdf"))
  fileList<-c(fileList,paste0(dirname[[run]],common[run],catchType[run],"DataSummary.pdf"))
}
if(NumCores>3 & numSp>1) stopCluster(cl)
pdf_combine(fileList,paste0(outDir,"\\DataSummary.pdf"))
file.copy(specFile,paste0(outDir,"\\",Sys.Date(),"BycatchModelSpecification.r"))

