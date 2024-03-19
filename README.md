# Numbeo-Data-Analytics-Project

## Prerequisites

- [Python](https://www.python.org/) (recommended version >= v3.10.11)
    - [requests](https://pypi.org/project/requests/) library (pip install requests): used to get pages
    - [BeautifulSoup](https://pypi.org/project/beautifulsoup4/) library (pip install beautifulsoup4): used to parse html code
    - [Pandas](https://pandas.pydata.org/) (pip install pandas): used to work with DataFrames
    - [geopy](https://pypi.org/project/geopy/) (pip install geopy): used to get latitude and longitude for cities
- [Tableau public](https://www.tableau.com/products/desktop/download): used for Visualizations
- Jupyter Notebooks (I used it with [Anaconda Navigator](https://www.anaconda.com/anaconda-navigator))
- [SQL Server Management Studio 19](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16) (SSMS): SSMS is required for interacting with the SQL Server databases used
in this project.

## Objective
The main objective is to find the city where you will have the most money from your salary left after your monthly spending on food, rent, and bills. These metrics will be calculated as Average Salary - (food spending + average rent prices + bills). For specific details, you can refer to the Numbeo_Data_Analysis.sql file.

The second objective is to find the city with the highest Return on Investment for the bought house when you rent it out. These metrics will be calculated as Average rent price for an apartment / (divided by) Average price for a 1-bedroom (30 Square Meters) or 3-bedroom (80 Square Meters) apartment in the City center or Outside the center. For specific details, you can refer to the Numbeo_Data_Analysis.sql file.

I developed a Web Scraping script to get prices for cities from the Numbeo Website. The dataset includes 1000+ cities, URLs for each of them, latitude, longitude, and population.

## Conclusion of project
1. You will have the most money left from average salary in Switzerland (Zurich top 1) and United States cities
2. 1 bedroom apartment have higher Return on Investment rates than 3 bedrooms apartments
3. Best cities for such an investment are located in United States
4. Tashkent, Bishkek and Astana have high ROI rate (around 1.5% for 1 bedroom apartment) and it is relatively cheap to buy a house there (30,000-40,000$), so they are quite good places to start

Link on Tableau Visualization:
https://public.tableau.com/views/Numbeo_17105477412580/Numbeo_Project?:language=en-US&publish=yes&:sid=&:display_count=n&:origin=viz_share_link

![Tableau_Visualization.png](https://github.com/DZA-Mirai/Numbeo-Data-Analytics-Project/blob/f8b3838242721341e036a02916d92c5a54d83176/Numbeo_Visualization.png)
