
# install.packages("renv") # if not already installed, install renv from CRAN
renv::activate()
renv::restore() # this should prompt you to install the various packages required for the study


# packages -----
# load the below packages 
# you should have them all available, with the required version, after
# having run renv::restore above
library(DatabaseConnector)
library(CohortDiagnostics)
library(CirceR)
library(CohortGenerator)
library(here)
library(stringr)

# database metadata and connection details -----
# The name/ acronym for the database
db.name<-"..."

# database connection details
server<-"..."
user<-"..."
password<- "..."
port<-"..."
host<-"..."

# driver for DatabaseConnector
downloadJdbcDrivers("...", here()) # if you already have this you can omit and change pathToDriver below
connectionDetails <- createConnectionDetails(dbms = "...",
                                             server =server,
                                             user = user,
                                             password = password,
                                             port = port ,
                                             pathToDriver = here())

# sql dialect used with the OHDSI SqlRender package
targetDialect <-"..." 
# schema that contains the OMOP CDM with patient-level data
cdm_database_schema<-"..."
# schema that contains the vocabularie
vocabulary_database_schema<-"..."
# schema where a results table will be created 
results_database_schema<-"..."

# stem for tables to be created in your results schema for this analysis
# You can keep the above names or change them
# Note, any existing tables in your results schema with the same name will be overwritten
cohortTableStem<-"..."

# Run analysis ----
source(here("RunAnalysis.R"))

# Generate results for review -----
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = here("Results"))

# Review results -----
# if you want to review the results locally: 
# Download the following repo, open the project file and run renv::restore:
# https://github.com/oxford-pharmacoepi/CancerExtrapolationDiagnostics
# Put the premerge file from cohortdiagnostics and place it into the data folder of this repo.
# Click run app in top right of this window. Your results should open up to view.
