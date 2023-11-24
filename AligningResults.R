#Make results compatable ---- 

library(dplyr)
library(here)

# place results files in to align folder
# remove other zipped files from filter folder (apart from CPRD gold/aurum)
# removed zip files from for shiny folder
# run align argument
# run filter arugument
# run premerge argument

# This runs to make all cohort numbers consistent as some data partners can only run certain conditions
# naming dataframe (namingdf) is a dataframe of 2 columns containing the cohort_ID and the cohort name for the current
# cohort diagnostics outputs you want to convert 
cohort_id <- c(seq(1:8))
cohort_name <- c("IncidentBreastCancer",
                 "IncidentColorectalCancer",
                 "IncidentHeadNeckCancer",
                 "IncidentLiverCancer",
                 "IncidentLungCancer",
                 "IncidentPancreaticCancer",
                 "IncidentProstateCancer",
                 "IncidentStomachCancer"
                 
)

namingdf <- as.data.frame(cbind(cohort_id, cohort_name)) %>%
  mutate(cohort_id = as.numeric(cohort_id))

aligningresults <-
  function(inputFolder,
           outputFolder,
           namingdf) {

    tempFolder <- tempdir()
    unzipFolder <- tempfile(tmpdir = tempFolder)
    dir.create(path = unzipFolder, recursive = TRUE)
    on.exit(unlink(unzipFolder, recursive = TRUE), add = TRUE)

    zipFiles <-
      list.files(
        path = inputFolder,
        pattern = ".zip",
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = TRUE
      )

    if (length(zipFiles) == 0) {
      stop("Did not find zipped file in inputFolder location")
    }

    resultsDataModel <-
      CohortDiagnostics::getResultsDataModelSpecifications()
    tablesInResultsDataModel <- resultsDataModel %>%
      dplyr::select(.data$tableName) %>%
      dplyr::distinct() %>%
      dplyr::arrange() %>%
      dplyr::pull(.data$tableName)


    for (i in (1:length(zipFiles))) {
      ParallelLogger::logInfo("Unzipping ", basename(zipFiles[[i]]))
      exportDirectory <-
        file.path(unzipFolder, i, tools::file_path_sans_ext(basename(zipFiles[[i]])))
      utils::unzip(zipfile = zipFiles[[i]],
                   junkpaths = FALSE,
                   exdir = exportDirectory)
      listOfFilesInZippedFolder <-
        list.files(path = exportDirectory, pattern = ".csv")

      for (j in (1:length(tablesInResultsDataModel))) {
        if (paste0(tablesInResultsDataModel[[j]], ".csv") %in% listOfFilesInZippedFolder) {
          dataFromZip <-
            readr::read_csv(file = file.path(
              exportDirectory,
              paste0(tablesInResultsDataModel[[j]], ".csv")
            ),
            col_types = readr::cols()) # if csv file is in list of zipped files then read it

          if ("cohort_id" %in% colnames(dataFromZip)) {

            if(paste0(tablesInResultsDataModel[[j]], ".csv") == "cohort.csv"){

              dataFromZip <- dataFromZip %>%
                dplyr::inner_join(x = ., y = namingdf, by = c("cohort_id"))

              dataFromZip <- dataFromZip %>%
                dplyr::mutate(cohort_id = case_when(cohort_name.y == "HeadNeckSubtypeCancerHypopharynx" ~ 1,
                                                    cohort_name.y == "HeadNeckSubtypeCancerLarynx"~ 2,
                                                    cohort_name.y == "HeadNeckSubtypeCancerNasalCavitySinus" ~3,
                                                    cohort_name.y == "HeadNeckSubtypeCancerNasopharynx"~ 4,
                                                    cohort_name.y == "HeadNeckSubtypeCancerOralCavityIncidence"~ 5,
                                                    cohort_name.y == "HeadNeckSubtypeCancerOralCavityPrevalent"~ 6,
                                                    cohort_name.y == "HeadNeckSubtypeCancerOropharynx"~ 7,
                                                    cohort_name.y == "HeadNeckSubtypeCancerSalivaryGland"~ 8,
                                                    cohort_name.y == "HeadNeckSubtypeCancerTongueIncidence"~ 9,
                                                    cohort_name.y == "HeadNeckSubtypeCancerTonguePrevalent"~ 10,
                                                    cohort_name.y == "IncidentBreastCancer"~ 11,
                                                    cohort_name.y == "IncidentColorectalCancer"~ 12,
                                                    cohort_name.y == "IncidentEsophagealCancer"~ 13,
                                                    cohort_name.y == "IncidentHeadNeckCancer"~ 14,
                                                    cohort_name.y == "IncidentLiverCancer"~ 15,
                                                    cohort_name.y == "IncidentLungCancer"~ 16,
                                                    cohort_name.y == "IncidentPancreaticCancer"~ 17,
                                                    cohort_name.y == "IncidentProstateCancer"~ 18,
                                                    cohort_name.y == "IncidentStomachCancer"~ 19,
                                                    cohort_name.y == "PrevalentBreastCancer"~ 20,
                                                    cohort_name.y == "PrevalentColorectalCancer"~ 21,
                                                    cohort_name.y == "PrevalentEsophagealCancer"~ 22,
                                                    cohort_name.y == "PrevalentHeadNeckCancer"~ 23,
                                                    cohort_name.y == "PrevalentLiverCancer"~ 24,
                                                    cohort_name.y == "PrevalentLungCancer"~ 25,
                                                    cohort_name.y == "PrevalentPancreaticCancer"~ 26,
                                                    cohort_name.y == "PrevalentProstateCancer"~ 27,
                                                    cohort_name.y == "PrevalentStomachCancer" ~28 )) %>%
                dplyr::select(-(cohort_name.y)) %>%
                dplyr::rename(cohort_name = cohort_name.x)

            }

            if(paste0(tablesInResultsDataModel[[j]], ".csv") != "cohort.csv"){
              dataFromZip <- dataFromZip %>%
                dplyr::inner_join(x = ., y = namingdf, by = c("cohort_id"))

              dataFromZip <- dataFromZip %>%
                dplyr::mutate(cohort_id = case_when(cohort_name == "HeadNeckSubtypeCancerHypopharynx" ~ 1,
                                                    cohort_name == "HeadNeckSubtypeCancerLarynx"~ 2,
                                                    cohort_name == "HeadNeckSubtypeCancerNasalCavitySinus" ~3,
                                                    cohort_name == "HeadNeckSubtypeCancerNasopharynx"~ 4,
                                                    cohort_name == "HeadNeckSubtypeCancerOralCavityIncidence"~ 5,
                                                    cohort_name == "HeadNeckSubtypeCancerOralCavityPrevalent"~ 6,
                                                    cohort_name == "HeadNeckSubtypeCancerOropharynx"~ 7,
                                                    cohort_name == "HeadNeckSubtypeCancerSalivaryGland"~ 8,
                                                    cohort_name == "HeadNeckSubtypeCancerTongueIncidence"~ 9,
                                                    cohort_name == "HeadNeckSubtypeCancerTonguePrevalent"~ 10,
                                                    cohort_name == "IncidentBreastCancer"~ 11,
                                                    cohort_name == "IncidentColorectalCancer"~ 12,
                                                    cohort_name == "IncidentEsophagealCancer"~ 13,
                                                    cohort_name == "IncidentHeadNeckCancer"~ 14,
                                                    cohort_name == "IncidentLiverCancer"~ 15,
                                                    cohort_name == "IncidentLungCancer"~ 16,
                                                    cohort_name == "IncidentPancreaticCancer"~ 17,
                                                    cohort_name == "IncidentProstateCancer"~ 18,
                                                    cohort_name == "IncidentStomachCancer"~ 19,
                                                    cohort_name == "PrevalentBreastCancer"~ 20,
                                                    cohort_name == "PrevalentColorectalCancer"~ 21,
                                                    cohort_name == "PrevalentEsophagealCancer"~ 22,
                                                    cohort_name == "PrevalentHeadNeckCancer"~ 23,
                                                    cohort_name == "PrevalentLiverCancer"~ 24,
                                                    cohort_name == "PrevalentLungCancer"~ 25,
                                                    cohort_name == "PrevalentPancreaticCancer"~ 26,
                                                    cohort_name == "PrevalentProstateCancer"~ 27,
                                                    cohort_name == "PrevalentStomachCancer" ~28 )) %>%
                dplyr::select(-(cohort_name))

            }

          }

          if ("target_cohort_id" %in% colnames(dataFromZip)) {

            dataFromZip <- dataFromZip %>%
              dplyr::inner_join(x = ., y = namingdf, by = c("target_cohort_id" = "cohort_id"))

            dataFromZip <- dataFromZip %>%
              dplyr::mutate(target_cohort_id = case_when(cohort_name == "HeadNeckSubtypeCancerHypopharynx" ~ 1,
                                                         cohort_name == "HeadNeckSubtypeCancerLarynx"~ 2,
                                                         cohort_name == "HeadNeckSubtypeCancerNasalCavitySinus" ~3,
                                                         cohort_name == "HeadNeckSubtypeCancerNasopharynx"~ 4,
                                                         cohort_name == "HeadNeckSubtypeCancerOralCavityIncidence"~ 5,
                                                         cohort_name == "HeadNeckSubtypeCancerOralCavityPrevalent"~ 6,
                                                         cohort_name == "HeadNeckSubtypeCancerOropharynx"~ 7,
                                                         cohort_name == "HeadNeckSubtypeCancerSalivaryGland"~ 8,
                                                         cohort_name == "HeadNeckSubtypeCancerTongueIncidence"~ 9,
                                                         cohort_name == "HeadNeckSubtypeCancerTonguePrevalent"~ 10,
                                                         cohort_name == "IncidentBreastCancer"~ 11,
                                                         cohort_name == "IncidentColorectalCancer"~ 12,
                                                         cohort_name == "IncidentEsophagealCancer"~ 13,
                                                         cohort_name == "IncidentHeadNeckCancer"~ 14,
                                                         cohort_name == "IncidentLiverCancer"~ 15,
                                                         cohort_name == "IncidentLungCancer"~ 16,
                                                         cohort_name == "IncidentPancreaticCancer"~ 17,
                                                         cohort_name == "IncidentProstateCancer"~ 18,
                                                         cohort_name == "IncidentStomachCancer"~ 19,
                                                         cohort_name == "PrevalentBreastCancer"~ 20,
                                                         cohort_name == "PrevalentColorectalCancer"~ 21,
                                                         cohort_name == "PrevalentEsophagealCancer"~ 22,
                                                         cohort_name == "PrevalentHeadNeckCancer"~ 23,
                                                         cohort_name == "PrevalentLiverCancer"~ 24,
                                                         cohort_name == "PrevalentLungCancer"~ 25,
                                                         cohort_name == "PrevalentPancreaticCancer"~ 26,
                                                         cohort_name == "PrevalentProstateCancer"~ 27,
                                                         cohort_name == "PrevalentStomachCancer" ~28)) %>%
              dplyr::select(-(cohort_name))

            dataFromZip <- dataFromZip %>%
              dplyr::inner_join(x = ., y = namingdf, by = c("comparator_cohort_id" = "cohort_id"))

            dataFromZip <- dataFromZip %>%
              dplyr::mutate(comparator_cohort_id = case_when(cohort_name == "HeadNeckSubtypeCancerHypopharynx" ~ 1,
                                                             cohort_name == "HeadNeckSubtypeCancerLarynx"~ 2,
                                                             cohort_name == "HeadNeckSubtypeCancerNasalCavitySinus" ~3,
                                                             cohort_name == "HeadNeckSubtypeCancerNasopharynx"~ 4,
                                                             cohort_name == "HeadNeckSubtypeCancerOralCavityIncidence"~ 5,
                                                             cohort_name == "HeadNeckSubtypeCancerOralCavityPrevalent"~ 6,
                                                             cohort_name == "HeadNeckSubtypeCancerOropharynx"~ 7,
                                                             cohort_name == "HeadNeckSubtypeCancerSalivaryGland"~ 8,
                                                             cohort_name == "HeadNeckSubtypeCancerTongueIncidence"~ 9,
                                                             cohort_name == "HeadNeckSubtypeCancerTonguePrevalent"~ 10,
                                                             cohort_name == "IncidentBreastCancer"~ 11,
                                                             cohort_name == "IncidentColorectalCancer"~ 12,
                                                             cohort_name == "IncidentEsophagealCancer"~ 13,
                                                             cohort_name == "IncidentHeadNeckCancer"~ 14,
                                                             cohort_name == "IncidentLiverCancer"~ 15,
                                                             cohort_name == "IncidentLungCancer"~ 16,
                                                             cohort_name == "IncidentPancreaticCancer"~ 17,
                                                             cohort_name == "IncidentProstateCancer"~ 18,
                                                             cohort_name == "IncidentStomachCancer"~ 19,
                                                             cohort_name == "PrevalentBreastCancer"~ 20,
                                                             cohort_name == "PrevalentColorectalCancer"~ 21,
                                                             cohort_name == "PrevalentEsophagealCancer"~ 22,
                                                             cohort_name == "PrevalentHeadNeckCancer"~ 23,
                                                             cohort_name == "PrevalentLiverCancer"~ 24,
                                                             cohort_name == "PrevalentLungCancer"~ 25,
                                                             cohort_name == "PrevalentPancreaticCancer"~ 26,
                                                             cohort_name == "PrevalentProstateCancer"~ 27,
                                                             cohort_name == "PrevalentStomachCancer" ~28)) %>%
              dplyr::select(-(cohort_name))

          }

          readr::write_excel_csv(
            x = dataFromZip,
            file = file.path(
              exportDirectory,
              paste0(tablesInResultsDataModel[[j]], ".csv")
            ),
            na = "",
            quote = "all",
            append = FALSE
          )
        }
      }

      dir.create(path = outputFolder,
                 showWarnings = FALSE,
                 recursive = TRUE)
      DatabaseConnector::createZipFile(
        zipFile = file.path(outputFolder, basename(zipFiles[[i]])),
        files = list.files(
          path = exportDirectory,
          pattern = ".csv",
          full.names = TRUE,
          include.dirs = TRUE
        ),
        rootFolder = exportDirectory
      )
    }

  }


aligningresults(inputFolder = here("Results", "ToAlign" ),
                outputFolder = here("Results", "ToFilter"),
                namingdf = namingdf

)
# 
#remove cohorts we do not need
subsetResultsZip <-
  function(inputFolder,
           outputFolder,
           cohortIds) {

    checkmate::assertIntegerish(
      x = cohortIds,
      any.missing = FALSE,
      min.len = 1,
      null.ok = FALSE
    )

    tempFolder <- tempdir()
    unzipFolder <- tempfile(tmpdir = tempFolder)
    dir.create(path = unzipFolder, recursive = TRUE)
    on.exit(unlink(unzipFolder, recursive = TRUE), add = TRUE)

    zipFiles <-
      list.files(
        path = inputFolder,
        pattern = ".zip",
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = TRUE
      )

    if (length(zipFiles) == 0) {
      stop("Did not find zipped file in inputFolder location")
    }

    resultsDataModel <-
      CohortDiagnostics::getResultsDataModelSpecifications()
    tablesInResultsDataModel <- resultsDataModel %>%
      dplyr::select(.data$tableName) %>%
      dplyr::distinct() %>%
      dplyr::arrange() %>%
      dplyr::pull(.data$tableName)

    for (i in (1:length(zipFiles))) {
      ParallelLogger::logInfo("Unzipping ", basename(zipFiles[[i]]))
      exportDirectory <-
        file.path(unzipFolder, i, tools::file_path_sans_ext(basename(zipFiles[[i]])))
      utils::unzip(zipfile = zipFiles[[i]],
                   junkpaths = FALSE,
                   exdir = exportDirectory)
      listOfFilesInZippedFolder <-
        list.files(path = exportDirectory, pattern = ".csv")

      for (j in (1:length(tablesInResultsDataModel))) {
        if (paste0(tablesInResultsDataModel[[j]], ".csv") %in% listOfFilesInZippedFolder) {
          dataFromZip <-
            readr::read_csv(file = file.path(
              exportDirectory,
              paste0(tablesInResultsDataModel[[j]], ".csv")
            ),
            col_types = readr::cols())

          if ("cohort_id" %in% colnames(dataFromZip)) {
            dataFromZip <- dataFromZip %>%
              dplyr::filter(.data$cohort_id %in% cohortIds)
          }


          if ("target_cohort_id" %in% colnames(dataFromZip)) {
            dataFromZip <- dataFromZip %>%
              dplyr::filter(.data$target_cohort_id %in% cohortIds) %>%
              dplyr::filter(.data$comparator_cohort_id %in% cohortIds)

          }



          readr::write_excel_csv(
            x = dataFromZip,
            file = file.path(
              exportDirectory,
              paste0(tablesInResultsDataModel[[j]], ".csv")
            ),
            na = "",
            quote = "all",
            append = FALSE
          )
        }
      }

      dir.create(path = outputFolder,
                 showWarnings = FALSE,
                 recursive = TRUE)
      DatabaseConnector::createZipFile(
        zipFile = file.path(outputFolder, basename(zipFiles[[i]])),
        files = list.files(
          path = exportDirectory,
          pattern = ".csv",
          full.names = TRUE,
          include.dirs = TRUE
        ),
        rootFolder = exportDirectory
      )
    }
  }

# only includes cancer jsons we want
subsetResultsZip(inputFolder = here("Results", "ToFilter"),
                 outputFolder = here("Results", "ForShiny"),
                 cohortIds = c(11,12,14,15,16,17,18,19
                 )
)
# 
# 
# # create premerge -----
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = here("Results", "ForShiny"))




