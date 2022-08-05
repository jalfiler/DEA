
# Data Exploration Project

In this project you will be compiling together some messy real-world data, and then designing an analysis to answer a **research question**:


"The College Scorecard was released at the start of September 2015. Among colleges that predominantly grant bachelor’s degrees, did the release of the Scorecard shift student interest to high-earnings colleges relative to low-earnings ones (as proxied by Google searches for keywords associated with those colleges)?"


## The Data

The ZIP file `Data_Exploration_Rawdata.zip` contains a number of files:

* `trends_up_to_....csv`: These are files generated using Google Trends. They are the Google Trends index for each `keyword` for the given `monthorweek`. Each keyword (indexed with `keynum`) is selected to be reflective of a university in the United States, given by `schname`. There are multiple files because the Google Trends API will kick you off if you make too many requests, and you have to start again.
* `Most+Recent+Cohorts+(Scorecard+Elements).csv`: This is data from the College Scorecard, a simple dataset that contains lots of information about United States colleges and the students that graduate from them. The variable names aren’t super helpful but they are documented in `CollegeScorecardDataDictionary-09-08-2015.csv`
* `id_name_link.csv`, which can be used to match colleges as identified in the Scorecard data (by `unitid` and `opeid` / `UNITID` and `OPEID`) with colleges as identified in the Google Trends data (by `schname`). The `join` functions will be helpful (see `help(join)` after loading the **tidyverse**)

## The Analysis
The College Scorecard isn’t just data for us - it’s also treatment! The College Scorecard is a public-facing website that contains important information about colleges, including how much its graduates earn. This information has traditionally been very difficult to find.


* Produce at least one regression and one graph for your analysis, and explain them.
* There is a variable in the Scorecard with information about the median earnings of graduates ten years after graduation for each college. But how can we define “high-earning” and “low-earning” colleges? There’s not a single answer - be ready to defend your choice.
* What level should the data be at? You can leave the data as is, with one row per week per keyword. Or `group_by` and `summarize` to put things to one week per college, or one month per college, or one mont per keyword, etc. etc.
* How should the regression model be designed to answer the question (transformations and functional form? Standard error adjustments? etc.), and how can we interpret the results once we have them?

**Notes:**
When you’ve got a model, ask yourself: 
* (a) how will the results to this model answer the research question? and 
* (b) does this model make sense? 

You can help yourself out here by interpreting your coefficients carefully. Without an interaction term this might be *“This coefficient means that for every one-unit increase in A, controlling for the other variables in the model, we expect a (something)-unit increase in B.”* 

Does that sentence provide information about the research question? Continue that sentence with “and so the introduction of the Google Scorecard (does what?)” 

The dependent variable should be the outcome. When you “control for other variables” are those the variables you want to control for?

## The Report
Make an RMarkdown file that performs your analysis and displays the results, and in which you explain your analysis.

Be sure to:

* Include at least one regression and one graph
* Explain why you are performing the analysis you are performing, and the choices you made in putting it together
* Explain how your analysis addresses the research question
* Any additional analyses you did that led you to design your main analysis that way (i.e. “I graphed Y vs. X and it looked nonlinear so I added a polynomial term” - you could even include this additional analysis if you like)
* Explain what we should conclude, in real world terms, based on your results
