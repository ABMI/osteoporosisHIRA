renv::deactivate()

library(bisphosphonate)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "temp directory")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# The folder where the study intermediate and result files will be written:
outputFolder <- "./bisphosphonateResult" # output folder directory

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "dbms",
                                                                server = 'server',
                                                                user = 'user',
                                                                password = 'password',
                                                                port = 'port')

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- ""

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- ""
cohortTable <- "hihipch_bisphosphonate"

# Some meta-information that will be used by the export function:
databaseId <- "HIRA"
databaseName <- "HIRA"
databaseDescription <- "HIRA"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        createCohorts = T,
        synthesizePositiveControls = F,
        runAnalyses = T,
        packageResults = T,
        maxCores = maxCores)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
privateKeyFileName <- ""
userName <- ""
uploadResults(outputFolder, privateKeyFileName, userName)
