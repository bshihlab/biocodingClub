### Background 
# This is the short instruction for Exercise D - Crash course on making plots in R
# Any words after a # symbol are called "comments", meaning that they are not part of the code
# I will describe what each part of the code do with comment lines


### Setting
# !!! You will need to change the variables listed under this section. Explanation added after ##!!
working_dir <- "C:/Users/username/exercise_folder"									  ##!! Change this to your working directory. "~/" is the default folder, usually "My documents" on Windows.
input_fp <- "data/virus.csv"					##!! Need to be changed to your input file
output_dir <- "output"                ## The name of the output folder. 
output_ggplot_fp <- "dotplot_virus.pdf"			##!! Need to be changed to intended output file name
output_plotly_fp <- "dotplot_virus.html"			##!! Need to be changed to intended output file name
colname_annotation_data <- "Organism_Name" 		##!! Extra annotation. Need be changed to any column names in your input file. 
colname_x_data <- "Size_Kb"							      ##!! Column name for the x-axis. Need to be a column name in your input file.
colname_y_data <- "Number_Of_Proteins"				##!! Column name for the y-axis. Need to be a column name in your input file.

# Figure labels
label_title <- "The size of viral genome versus the number of proteins"		##!! Plot title
label_x <- "Size (kilobase)"												##!! X-axis label
label_y <- "Number of proteins"												##!! Y-axis label

# Make the output directory if it doesn't already exist
dir.create(output_dir, showWarnings=FALSE)
# Add the output directory to the output file paths
output_ggplot_fp <- paste(output_dir, output_ggplot_fp, sep="/")
output_plotly_fp <- paste(output_dir, output_plotly_fp, sep="/")


### Install and load libraries
# This part download and load R libraries. 
# You can think of it like when you download apps onto your phone.
## Install library
# In the first line, it is saying "You require a library called ggplot2, if this library is not already installed, install it, and do it quietly (i.e. don't ask me a bunch of questions about it)")
# A bunch of red lines will come up 
if(!require("ggplot2", quietly = TRUE)){ install.packages("ggplot2") }
if(!require("plotly", quietly = TRUE)){ install.packages("plotly") }

## Load library
library(ggplot2)
library(plotly)


## Set the working directory
setwd(working_dir)


### Read in the data file into a dataframe
plot_df <- read.csv(input_fp)

### Make plot
## ggplot to print plot into a file
# You can find a library of code on how to make different plot here https://plotly.com/ggplot2/
ggplot(data=plot_df, aes(x=.data[[colname_x_data]], y=.data[[colname_y_data]], colour=.data[[colname_x_data]])) + 
		geom_point( size=0.5 ) + 
		theme_bw() +
		xlab(label_x) + ylab(label_y) + ggtitle(label_title)
# Save the graph
ggsave(output_ggplot_fp, width = 6, height =4)


## Plotly to make interactive plots
# You can find a library of code on how to make different plot here https://plotly.com/r/
x <- plot_df[[colname_x_data]]
y <- plot_df[[colname_y_data]]
plot_text <- plot_df[[colname_annotation_data]]
plot_color <- plot_df[[colname_x_data]]
p2 <- plot_ly(x = ~x, y = ~y, 
		text = ~plot_text,
		color = ~plot_color,
		type = "scatter", 
		mode = "markers",
		marker = list(size = 4))
# Add titles and axis labels
p2 <- layout(p2, title = label_title, 
		xaxis = list(title = label_x),
		yaxis = list(title = label_y))
p2 <- colorbar(p2, title = label_x)
# Save the interactive plotly plot as a html. Notice that here I used htmlwidgets:: 
# This tells R that the function saveWidget came from the htmlwidgets package
# It is useful to specify where your functions come from in case different packages use the same function name
htmlwidgets::saveWidget(as_widget(p2), output_plotly_fp)
