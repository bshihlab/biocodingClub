# Introduction to R (Day 2)
## 1. List
Lists are R objects that can contain elements of different types.
### Task 1.1
```r
# Making lists
myMeals = list(breakfast="toast", lunch="sandwich", dinner="pie")

myMeals = list(breakfast=c("toast", "egg", "coffee"), 
                lunch=c("sandwich", "crisps"), 
                dinner=c("pie", "apple"))

# Unlike vectors where all values need to be of one data type 
# (i.e. when you do c(1, 3, "a"), the whole vector will become a character vector)
# You can have a mixture of different data types in a list
myMeals = list(breakfast=data.frame(food=c("toast", "egg", "coffee"), cost=c(1,3,3)), 
                lunch=c("sandwich", "crisps"), 
                dinner=c("pie", "apple"))

str(myMeals)
```

### Task 1.2
```r
myMeals$breakfast
myMeals$breakfast$food
myMeals$breakfast$cost

# Double/single square brackets
doubleBracket <- myMeals[["breakfast"]]
singleBracket <- myMeals["breakfast"]
myMeals[["breakfast"]][["food"]]
myMeals[["breakfast"]]["food"]

# Using a mixture
myMeals[["breakfast"]]$food
myMeals["breakfast"]$food
myMeals["breakfast"]$breakfast

```

### Task 1.3
```r
# Splitting a dataframe into a list
working_dir <- "C:/Users/shihb/OneDrive - Lancaster University/work/teaching/workshop/202307_r_introduction"
setwd(working_dir)

sample_annotation <- read.delim("data/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt")
sample_annotation <- sample_annotation[grepl("(s|S)kin", sample_annotation$SMTSD),]
sample_annotation_list <- split(sample_annotation, sample_annotation$SMTSD)
class(sample_annotation_list)
head(sample_annotation_list)
names(sample_annotation_list)

```

### Task 1.4
```r
# Splitting a string to generate list of character vectors
sampleID_split <- strsplit(sample_annotation$SAMPID, "-")
head(sampleID_split)
```

<br> </br>

## 2. Loops
### Task 2.1. Basic loop
```r
# For loop
# Loops are very useful for doing a similar process multiple times
# Go from 1 to 5
for(idx in 1:5){
	print(idx)
}
# Use loop to refer to different parts of a vector or list
items <- c("one", "two", "three", "four", "five")
for(idx in 1:length(items)){
	current_item <- items[idx]
	print_text <- paste0("This is: ", current_item)
	print(print_text)
}

```

### Task 2.2. You can also directly refer to each element in the vector/list
```r
# Rather than referring to the index, you can just refer to the item
for(current_item in items){
	print_text <- paste0("This is: ", current_item)
	print(print_text)
}
```

### Task 2.3
```r
# Loop through the list we generate earlier
# print the number of rows for each element
for(idx in 1:length(sample_annotation_list)){
	current_df <- sample_annotation_list[[idx]]
	current_sampleType <- names(sample_annotation_list)[idx]
	num_row <- nrow(current_df)
	print_text <- paste0(current_sampleType, "has a total of ", num_row, "rows.")
	print(print_text)	
}

# Save a copy of each element
# Create an output folder
dir.create("output", showWarnings = FALSE)
for(idx in 1:length(sample_annotation_list)){
	current_df <- sample_annotation_list[[idx]]
	current_sampleType <- names(sample_annotation_list)[idx]
	num_row <- nrow(current_df)

	# save the data frame
	out_fp <- paste0("output/", current_sampleType, ".csv")
	write.csv(current_df, out_fp, row.names=FALSE)
}

```
### Task 2.4. Nested loop

```r
# Loop 1
for(idx1 in 1:length(sample_annotation_list)){
	current_df <- sample_annotation_list[[idx1]]
	current_sampleType <- names(sample_annotation_list)[idx1]
	# Loop 2
	for(idx2 in 1:5){
		current_sampleName <- current_df$SAMPID[idx2]
		print_text <- paste0(current_sampleType, "sample ", idx2, ": ", current_sampleName)
		print(print_text)
	}
}
```


<br> </br>

## 3. Functions
### Task 3.1
```r
# We have already used a few in-built functions
class(read.delim)
class(class)
```
### Task 3.2
```r
# We can make our own functions to save time 
myFun_colour <- function(favCol){
	out_line <- paste0("My favourite colour is ", favCol)
	return(out_line)
}
# Try out the function
myFun_colour("red")
myFun_colour("green")

# More than one input
myFun_colour <- function(favCol, leastFavCol){
	out_line <- paste0("My favourite colour is ", favCol, ", and my least favourite colour is ", leastFavCol)
	return(out_line)
}
myFun_colour("red", "black")
myFun_colour("red")
```
### Task 3.3
```r
# Setting a default
myFun_colour <- function(favCol, leastFavCol = "black"){
	out_line <- paste0("My favourite colour is ", favCol, ", and my least favourite colour is ", leastFavCol)
	return(out_line)
}
myFun_colour("red")
myFun_colour("red", "green")

# Look at in-built functions
?read.delim
?mean
?sd

```
### Task 3.4
```r
# Not specifying output
myFun_colour <- function(favCol, leastFavCol = "black"){
	paste0("My favourite colour is ", favCol, ", and my least favourite colour is ", leastFavCol)
}
myFun_colour("red")

```
<br> </br>

## 4. List + function. Apply, sapply, lapply
### Task 4.1
```r
# set working directory
working_dir <- "C:/Users/shihb/OneDrive - Lancaster University/work/teaching/workshop/202307_r_introduction"
setwd(working_dir)

# Read in metadata
sample_annotation <- read.delim("data/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt")
subject_annotation <- read.delim("data/GTEx_Analysis_v8_Annotations_SubjectPhenotypesDS.txt")

# In order to merge the two columns, We need to have a column in sample_annotation that matches to SUBJID in subject_annotation
# Splitting a string to generate list of character vectors
sampleID_split <- strsplit(sample_annotation$SAMPID, "-")
head(sampleID_split)

# For loop
# declare an empty vector
combined <- vector()
for(idx in 1:length(sampleID_split)){
    current_strings <- sampleID_split[[idx]]
    combined[idx] <- paste0(current_strings[1], "-", current_strings[2])
}
```

### Task 4.2
```r
# sapply (takes vector or lists as inputs and returns vectors)
combined <- sapply(sampleID_split, FUN=function(x)paste0(x[1], "-", x[2]))
combined <- sapply(strsplit(sample_annotation$SAMPID, "-"), FUN=function(x)paste0(x[1], "-", x[2]))

# lapply (takes vector or lists as inputs returns lists)
combined_lapply <- lapply(sampleID_split, FUN=function(x)paste0(x[1], "-", x[2]))

# apply (takes data frame or matrix as inputs and return vectors, lists or array)
head(sample_annotation[,1:5])
combined_apply <- apply(sample_annotation, MARGIN=1, FUN=function(x)paste0(strsplit(x[1], "-")[[1]][1:2], collapse="-"))
```
<br> </br>

## 5. If statements
### Task 5.1
```r
# Now we can merge between the subject metadata and sample metadata
sample_annotation$SUBJID <- combined
sample_annotation <- merge(sample_annotation, subject_annotation, by.x="SUBJID", by.y="SUBJID")

# Let's annotate age group
unique(sample_annotation$AGE)
ageGroup <- vector()
for(idx in 1:length(sample_annotation$AGE )){
    current_age <- sample_annotation$AGE[idx]
    if(current_age %in% c("60-69", "70-79")){
        ageGroup[idx] <- "Old"
    } else if(current_age %in% c("20-29", "30-39")){
        ageGroup[idx] <- "Young"
    } else {
        ageGroup[idx] <- "Middle"
    }
}
sample_annotation$ageGroup <- ageGroup
```
### Task 5.2
```r
# Short way to do the same thing
sample_annotation$ageGroup <- ifelse(sample_annotation$AGE %in% c("60-69", "70-79"), "Old", ifelse(sample_annotation$AGE %in% c("20-29", "30-39"), "Young", "Middle"))

```

<br> </br>

## 6. Libraries
### Task 6.1. Install a library
```r
# Other people have made libraries of useful functions
# Installing libraries
install.packages("ggplot2")
```

### Task 6.2. Use ggplot2 library
```r
# Importing libraries
library(ggplot2)

plot_df <- data.frame(Gene1=1:10, Gene2=1:10, Group=c(rep("Group1", 5), rep("Group2", 5)))
plot_df

p <- ggplot(data = plot_df, aes(x=Gene1, y=Gene2)) + geom_point()
p

# Split the graph by Group
p + facet_wrap(~Group)

# Change the theme
p + facet_wrap(~Group) + theme_bw()
```

### Task 6.3. Split plots
```r
# Plot by group
p <- ggplot(data = plot_df, aes(x=Group, y=Gene1)) + geom_point() + theme_bw()
# Spread the points so they don't overlap each other
p <- ggplot(data = plot_df, aes(x=Group, y=Gene1)) + geom_point(position = position_jitter(w = 0.2, h = 0)) + theme_bw()
# Colour points by Gene2
p <- ggplot(data = plot_df, aes(x=Group, y=Gene1, colour=Gene2)) + geom_point(size = 5, position = position_jitter(w = 0.2, h = 0)) + theme_bw()

```

### Task 6.4. Change colours
```r
# Change colour schemes
# Install library
install.packages("viridis")
library(viridis)

# Overwrite colour scheme
# https://sjmgarnier.github.io/viridis/reference/scale_viridis.html
p <- p + scale_color_viridis()
p <- p + scale_color_viridis(option="A")
```

