# Application Segmentation Using R
Create a Android mobile App segmentation using text analysis.

## Generl Code Info
### Google Play Scrapping
To get the description data from Google Play you need to have a list of
	package ids, for each id you will extract the App name and description.
	Code is in file "GetPlayData.r"


### Text Analysis - Cleaning
Clean all the text and make the description suitable for Text Analysis.

### App Segmentation 
After cleaning the text we can run our clustering algorithm

## Info About Data Input Files

### "pkg.data.info.25082015.csv"
    Include all the data after the scrapping process if you like to try the scraping code by yourself, 
    you can use the package id column from this file.
### "stopwords.txt" 
    Include many stop words nd key words I decided to remove from the text description this file is used during the text cleaning process.
### "pkg.data.info.stem.csv" 
    The stemming process is taking some time, so if you like to skip the execution of all the cleaning process 
    and run only the clustering phase, you ca use this file as input.
