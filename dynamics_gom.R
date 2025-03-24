#################################################################################################
################################ OSMOSE - Calibration using EA ##################################
#################################################################################################

dynamics  = function(par,forcing,default=NULL,constants=NULL,initial=NULL) {

  require(osmose2R)
  
  # par        : parameter vector, parameters which have been calibrated
  # forcing    : forcing variables for the model
  # default    : default values for parameters not calibrated
  # constants  : model constant, including simulation horizon
  # initial    : initial conditions for the model, structure of the population at start time
  
  parameters = par
  if(!is.null(default)) {
    parameters[is.na(par)]=default[is.na(par)] # use default values for parameters not calibrated.
    colnames(parameters) = colnames(default)
    rownames(parameters) = rownames(default)
  }
  
  path.tmp = getwd()
  on.exit(setwd(path.tmp))
  
  work.dir=file.path(run,paste0("i",i))
  
  species = c("King_mackerel", "Amberjacks", "Red_grouper", "Gag_grouper", "Red_snapper", "Sardine_herring_scad_complex", "Anchovies_and_silversides", "Coastal_omnivores", "Reef_carnivores", "Reef_omnivores", "Shrimps", "Large_crabs")

  plankton = c("Small_phytoplankton", "Diatoms", "Microzooplankton", "Mesozooplankton", "Meiofauna", "Small_infauna", "Small_mobile_epifauna", "Bivalves", "Echinoderms_and_large_gastropods")
  psp      = length(plankton)

# Loading model constants
  
  getSpNo = function(sp, species) which(species == sp) - 1
  
# Loading model parameters

  M.larval      = parameters["larval.mortality", species]
  A.plankton    = 10^(-parameters["plankton.access", seq_len(psp)])

  setwd(work.dir)      			# change directory to this individual directory
  
  calibration.conf = readOsmoseParameters(file="calibration-parameters.csv")
  
  pars.sp  = "mortality.natural.larva.rate"
  
  pars.plk = "plankton.accessibility2fish"
  
  
  for(isp in species) {
    n = getSpNo(isp, species)
    calibration.conf[[paste0(pars.sp, ".sp", n)]] = as.numeric(M.larval[isp])
  }
  
  for(ipk in seq_len(psp)) {
    calibration.conf[[paste0(pars.plk, ".plk", ipk-1)]] = as.numeric(A.plankton[ipk])  
  }
  
  # writing parameters
  writeOsmoseParameters(calibration.conf, "calibration-parameters.csv")
  cat("Write Osmose parameters OK", "\n")

# Derived quantities

################################ Dynamics ###################################################

#run.osmose = "java -jar ~/ea/ea_gol/LIB/jar/osmose.jar config.csv output/"
javaexec="/appli/java/jdk1.7.0_25/bin/java -jar /home1/caparmor/agruss/ea/ea_gom_v3/LIB/jar/osmose.jar"
oinput=paste(work.dir, "config.csv", sep="/")
ooutput=paste(work.dir, "output", sep="/")
ooptions=paste(oinput, ooutput)
run.osmose=paste(javaexec, ooptions, ">& osmose.log")
 
cat(run.osmose, "\n") 
system(run.osmose, wait=TRUE)				# Run OSMOSE
cat("Run Osmose OK", "\n")

# Read OSMOSE biomass outputs
  osmose.biomass = apply(readOsmoseFiles(path="output", type="biomass"), c(1,2), mean)
  osmose.catches = apply(readOsmoseFiles(path="output", type="yield"), c(1,2), mean)

cat("Read Osmose outputs OK", "\n")

# Writing test
#  cat(work.dir,file=file.path(work.dir,"output/test.txt"))
  

################################ Outputs for calibration ####################################


# Defining outputs: the first 'n' outputs of the dynamic must be the 'n' variables to be calibrated 

  output = list(King_mackerel.biomass            	= osmose.biomass[,"King_mackerel"],
		Amberjacks.biomass            		= osmose.biomass[,"Amberjacks"],
		Red_grouper.biomass            		= osmose.biomass[,"Red_grouper"],
		Gag_grouper.biomass            		= osmose.biomass[,"Gag_grouper"],
		Red_snapper.biomass            		= osmose.biomass[,"Red_snapper"],
		Sardine_herring_scad_complex.biomass 	= osmose.biomass[,"Sardine_herring_scad_complex"],
		Anchovies_and_silversides.biomass       = osmose.biomass[,"Anchovies_and_silversides"],
		Coastal_omnivores.biomass            	= osmose.biomass[,"Coastal_omnivores"],
		Reef_carnivores.biomass            	= osmose.biomass[,"Reef_carnivores"],
		Reef_omnivores.biomass       		= osmose.biomass[,"Reef_omnivores"],
		Shrimps.biomass            		= osmose.biomass[,"Shrimps"],
		Large_crabs.biomass            		= osmose.biomass[,"Large_crabs"],
		King_mackerel.catch            		= osmose.catches[,"King_mackerel"],
		Amberjacks.catch            		= osmose.catches[,"Amberjacks"],
		Red_grouper.catch            		= osmose.catches[,"Red_grouper"],
		Gag_grouper.catch            		= osmose.catches[,"Gag_grouper"],
		Red_snapper.catch            		= osmose.catches[,"Red_snapper"],
		Sardine_herring_scad_complex.catch      = osmose.catches[,"Sardine_herring_scad_complex"],
		Anchovies_and_silversides.catch         = osmose.catches[,"Anchovies_and_silversides"],
		Coastal_omnivores.catch            	= osmose.catches[,"Coastal_omnivores"],
		Reef_carnivores.catch            	= osmose.catches[,"Reef_carnivores"],
		Shrimps.catch           		= osmose.catches[,"Shrimps"],
                Large_crabs.catch              		= osmose.catches[,"Large_crabs"]
  )
  
cat("Function dynamics OK", "\n")
return(output)

} 				# end of dynamic

#################################################################################################
################################ initialize RUN directory structure #############################
#################################################################################################

path.tmp=getwd()

setwd(lib)
files.master=paste("../LIB/master/",dir("master"),sep="")


setwd(run)

for(i in 1:seed) {
	new.dir=paste("i",i,sep="")
	if(!file.exists(new.dir)) dir.create(new.dir)
	file.copy(from=files.master,to=new.dir,recursive=TRUE)
}

setwd(path.tmp)


#################################################################################################

