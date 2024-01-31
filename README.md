CohortDiagnostics for Cancer Codelists
========================================================================================================================================================

## This is a fork (eric-fey-hus/hus_CancerSurvivalCohortDiagnistics) for HUS use in Acamedic. 

## R version
1) You must have R version 4.2.X to run this study script. If you have R versions 4.3.X or higher this script will not work so please downgrade your R version

## To Run
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project <i>StudyCohortDiagnostics.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Open and work though the <i>CodeToRun.R</i> file which should be the only file that you need to interact with. Run the lines in the file, adding your database specific information and so on (see comments within the file for instructions). The last line of this file will run the study <i>(source(here("RunStudy.R"))</i>.     
4) After running you should then have a zip folder with results to share in your output folder.

## Changing/ adding cohort definitions
Cohort definitions are in the folder 1_InstantiateCohorts\Cohorts. Whatever cohorts are present in this folder will be run, with the file name used as the name for the cohort.
