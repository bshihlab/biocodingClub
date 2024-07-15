#### Data Processing
# This script was used to generate the data used for Exercise D from downloaded raw data.
# It is not for creating plots in R - it's mainly for students who want to dive further into data science/getting grips with R.
# You would need to download the raw files from the links indicated in the comments after each input file

### Settings
working_dir <- "C:/Users/shihb/OneDrive - Lancaster University/work/teaching/biocodingClub/R/20240715_plotting_and_basics"
output_dir <- "data"
output_fp_virus <- "data/virus.csv" # You can specify a file in a folder by using /. The "data/" part in this means when I create the file, it will be in a folder called "data" in my working directory
output_fp_eukaryote <- "data/eukaryote.csv" 

input_fp_virus <- "data/viruses.txt"  # Downloaded from https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/. You can right click and save as. "data/" indicates that my file is in a folder called "data" in my working directory
input_fp_eukaryote <- "data/eukaryotes.txt"  # Downloaded from https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/. You can right click and save as. "data/" indicates that my file is in a folder called "data" in my working directory
input_fp_eukaryote_tax <- "data/taxdmp/names.dmp"  # This file has the common names for the taxa. I unzipped taxdump.zip downloaded from https://ftp.ncbi.nih.gov/pub/taxonomy/ - 



setwd(working_dir) # set working directory
dir.create(output_dir, showWarnings = FALSE) # make output folder if it doesn't already exist



### ExerciseD_virus.csv
## Read in Data
raw_data_virus <- read.delim(input_fp_virus)
## Trim rows 
# Because this is a very large dataset, I kept only viruses that 
# $ here refers to the column name. For example, processed_data_virus$Host refers to the column starts with Host. 
processed_data_virus <- raw_data_virus[raw_data_virus$Host %in% c("archaea", "fungi", "land plants", "human", "vertebrates", "bacteria", "invertebrates"), ]

## Change data type (class) for the numeric columns
# Chage the class of the column to "numeric". 
# This is because there are some missing values and R automatically treat it as "characters". 
# Classes are important as they have different property (for example, numeric values can be added, characters cannot)
# Notice there is a . after GC in the line below. In the original data, this should be a %, but R automatically convert any special symbols to . in the column names
# Be careful with spaces, symbols and capital letters. R need to know exactly what it is that you're referring to.
processed_data_virus$GC. <- as.numeric(processed_data_virus$GC.)
processed_data_virus$Proteins <- as.numeric(processed_data_virus$Proteins)

# Once you change any "characters" values into "numeric", they will turn into NA values (not available). 
# R dataframes are like tables in Excel. You can use [] to refer to [row, column]. For example, processed_data_virus[1,2] ask for the first row in the second column. 
# In the lines below, I asked it to remove any rows (notice that the is.na() part is before the comma inside the square brackets, that means I'm filtering rows).
# These next lines asked to keep lines are not NA - the ! symbol means "not" in R
processed_data_virus <- processed_data_virus[!is.na(processed_data_virus$GC.),]
processed_data_virus <- processed_data_virus[!is.na(processed_data_virus$Proteins),]
# Because there are multiple sequences with the same TaxID (taxonomy ID), I have kept only the first one by removing rows with duplicated TaxID
# Order the rows by the number of proteins, this is so that when I remove the duplicate TaxID, the most well annotated (highest number of proteins) is kept
processed_data_virus <- processed_data_virus[order(processed_data_virus$Proteins, decreasing=TRUE),]
# Remove duplicates
processed_data_virus <- processed_data_virus[!duplicated(processed_data_virus$TaxID),]
# Because there are a lot of entries and will take a long time to plot, I have "randomly" (see note on set.seed) selected 50% of the total amount of data to reduce the file size
set.seed(123) # setting seed allows "randomness" to be able to be replicated 
randomly_selected_index <- sample(x=1:nrow(processed_data_virus), size=nrow(processed_data_virus) * 0.1)
# Include all viruses with the word "poxvirus" and "herpesvirus"
poxvirus <- grep("poxvirus", processed_data_virus$X.Organism.Name)
herpesvirus <- grep("herpesvirus", processed_data_virus$X.Organism.Name)
selected_virus <- unique(c(randomly_selected_index, poxvirus, herpesvirus))
processed_data_virus <- processed_data_virus[selected_virus,]


## Trim columns
# Since there are a lot of columns that we won't be using, I have trimmed the dataset down to just the few we will be using
# Notice that now I'm removing columns, the column names are referenced after the comma in the square brackets 
processed_data_virus <- processed_data_virus[,c("TaxID", "X.Organism.Name", "Host", "GC.", "Size..Kb.", "Proteins")]
# I then changed the column names to something that would be easier to refer to
colnames(processed_data_virus) <- c("Taxonomy_ID", "Organism_Name", "Host", "GC_content", "Size_Kb", "Number_Of_Proteins") 

## Export out data 
# The tidied data is then printed as a csv file for the workshop
# By default, it will print out the row names, I didn't want that so I turned it as FALSE
write.csv(processed_data_virus, output_fp_virus, row.names=FALSE)



### ExerciseD_eukaryote.csv
## Read in data
raw_data_eukaryote <- read.delim(input_fp_eukaryote) 
names_dmp <- read.delim(input_fp_eukaryote_tax) 

## Trim rows (similar to before)
# Order the rows by the number of proteins, this is so that when I remove the duplicate TaxID, the most well annotated (highest number of proteins) is kept
processed_data_eukaryote <- raw_data_eukaryote[order(raw_data_eukaryote$Proteins, decreasing=TRUE),]
# Remove duplicates
processed_data_eukaryote <- processed_data_eukaryote[!duplicated(processed_data_eukaryote$TaxID),]

## make numeric columns numeric
processed_data_eukaryote$GC. <- as.numeric(processed_data_eukaryote$GC.)
processed_data_eukaryote$Proteins <- as.numeric(processed_data_eukaryote$Proteins)
# filter out NA
processed_data_eukaryote <- processed_data_eukaryote[!is.na(processed_data_eukaryote$GC.),]
processed_data_eukaryote <- processed_data_eukaryote[!is.na(processed_data_eukaryote$Proteins),]

## Create a dataframe that tells us the common names for the eukaryotes
# Select the relevant rows (only those with the common names for each taxid), and select only the relevant columns (only TaxID and common name)
common_name_convert  <- names_dmp[names_dmp$synonym == "common name", c("X1", "all")] 
# change the column names
colnames(common_name_convert) <- c("TaxID", "common_name") 
common_name_convert <- common_name_convert[!duplicated(common_name_convert$TaxID),]
# Label the GC content/genome size dataframe
processed_data_eukaryote <- merge(processed_data_eukaryote, common_name_convert, by.x="TaxID", by.y="TaxID")


## Trim columns
# Since there are a lot of columns that we won't be using, I have trimmed the dataset down to just the few we will be using
# Notice that now I'm removing columns, the column names are referenced after the comma in the square brackets 
processed_data_eukaryote <- processed_data_eukaryote[,c("TaxID", "X.Organism.Name", "Group", "SubGroup", "common_name", "GC.", "Size..Mb.", "Proteins")]
# I then changed the column names to something that would be easier to refer to
colnames(processed_data_eukaryote) <- c("Taxonomy_ID", "Organism_Name", "Group", "SubGroup",  "Common_Name", "GC_content", "Size_Mb", "Number_Of_Proteins") 

## Export out data 
# The tidied data is then printed as a csv file for the workshop
# By default, it will print out the row names, I didn't want that so I turned it as FALSE
write.csv(processed_data_eukaryote, output_fp_eukaryote, row.names=FALSE)

