import csv

# create wine_subset.csv that is first x wines of wine.csv
x = 1000


# add presence of keywords to dataset and write new dataset to file
with open("../wine.csv",'rb') as f2:
    with open("../wine_subset.csv",'wb') as f3:
        
        reader = csv.reader(f2)
        writer = csv.writer(f3) 
        
        for i in range(x+1):
            writer.writerow(next(reader))


