# er2-data-analysis

This repository will contain the data analysis work for the ER2: Returning Results to Participants Project in conjunction with the University of Oregon and the National Science Foundation. Repository manager is J. Elyse St Sauver, with additional contributors as named. For questions about this project, please get in touch with the repository manager. 

Additional contributors: 
Mira Cross

***

## A Guide to the Datasets in this Repository: 

The main Data Analysis script is in the "Data Analysis" folder. It references several datasets, for a summary of these, see below. (Notably, none of the data exports keep the fine details of what attribute levels are associated with the "Tukio 1/Tukio 2" scenario pair images that the participants see in each round of the DCE. To get this, join with the dataset I generated called scenario_dataset.csv). 

-- **`Kagera Survey Data: kagera_merged.csv`**. This data does not include Kagera DCE data. It is a concatenated csv from multiple SurveyCTO exports. 

-- **`Kagera DCE Data: kagera_merged_dce.csv`**. This is Kagera's DCE data, also a concatenated csv from multiple SurveyCTO exports. 

-- **`Dar Survey Data: dar_RR_RCT.dta`**. This data does not include Dar DCE data, or control/treatment assignment. It is a .dta file provided by the enumerator team. The main data analysis script has a line to output a .csv that is commented out, if you'd prefer to work with the data in this format or don't have access to Stata. 

-- **`Dar Treatment Assignment Data: dar_controlinfo.dta`**. This data is provided to us through Alfredo's contact with the Dar project's previous research team. It should absolutely never be shared without first consulting Alfredo. 

-- **`Dar DCE Data: dar_RR_RCT-DCE.dta`**. This is Dar's DCE data. It is a .dta file provided by the enumerator team. The main data analysis script has a line to output a .csv that is commented out, if you'd prefer to work with the data in this format or don't have access to Stata. 

-- **`Scenario Pair Attribute and Level Data: scenario_dataset_with_assignments.csv`**. 
This dataset is one I generated that has each DCE game's attribute levels for each option. It was created using the script "ER2 Script for Generating Scenario Pairs and Images.rmd", and to join this data with the other datasets, identify the columns in the other datasets that say "stitched_output_###". This is the name of the image that depicts both scenarios for the participants to choose between, and uniquely identifies a row in the scenario_dataset_with_assignments.csv that will tell you the attribute levels. 

***
## History of Generating the Scenario Pair Datasets and Images: 

In case it's helpful, here's a quick blurb about how the scenario pairs and images were generated. I origianlly used the "XDEPRECATED First attempt at script..." to try out different bundle design methods, but none of that work ended up being relevant to the eventual scenarios used in the experiment. The actual scenario pairs used in the experiment were generated using the procedure in the **`"ER2 Script for Generating the Scenario Pairs and Images.Rmd"`**. This uses an R package called jpeg to stitch together .jpeg file formats. 

(Notably, the 'jpeg' package does NOT recognize .jpg even though that extension is equivalent to .jpeg and should be interchangeable. All the assets in the Asset folder should be of the correct .jpeg format to use, but if they're not or you make new ones, you can "rename" the files on any MacOS computer to "name.jpeg" and it should work. If you're on a PC you can use an online .jpg or .png to .jpeg converter but I wouldn't recommend it. .png versions and .jpeg versions are available in the Google Drive folder for the existing DCE assets that Mira created.)

Since Kenya uses a different currency, I needed to regenerate the scenario images for Kenya using different assets for the compensation image. The currency isn't actually noted on the asset images themselves, but we needed to use different increments for Kenyan shillings instead of Tanzanian shillings. The quantity of levels and conversion is almost perfect though, so I don't think we need to worry much about converting the Kenyan data into Tanzanian currency or vice versa. To accomplish this task, I edited the old compensation image assets that Mira created using Canva, and used the **`"ImageGenerationforKenya.Rmd"`** script I wrote (you can find it in the Scenario Generation folder of this repo). The script takes in the existing dataset of Kagera/Dar/Unassigned scenarios, assigns the first remaining 1500 of them to Kenya, and then regenerates the images by stitching together the exisitng assets and the new compensation asset images (those are the 0Ksh.jpeg, 1Ksh.jpeg, etc. as opposed to the Tsh versions we used in Kagera and Dar). 

The output images are all of the format "stitched_output_###.jpeg." These are the unique identifiers of each DCE game. There are still about 500 scenarios  (enough for 50 participants) left over that haven't been used, and they're marked as "unassigned" in the scenario_dataset_with_assignments.csv. 
***

