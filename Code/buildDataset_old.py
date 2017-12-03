import csv
import timeit
# import time

# wine review/descrtiption is in column 2 of wine.csv
reviewcol = 2

# read m total keywords in dictionary (after subtracting corpus)
keywords = []
# with open("../keywords.txt") as f1: #for small-scale testing
print "Reading keywords..."
# start = timeit.timeit()
with open("../mergedFrequencies.txt") as f1:
    for line in f1:
        line = line.strip()
        keywords.append((line.split(":")[0]).upper().lower())
# end = timeit.timeit()
# print "time to read keywords: " + str(end-start)
print "number of keywords: " + str(len(keywords))

# add presence of keywords to dataset and write new dataset to file
print "Creating dataset..."
with open("../wine_subset.csv",'rb') as f2: #for small-scale testing
# with open("../wine.csv",'rb') as f2:
    with open("../dataset_subset.csv",'wb') as f3: #for small-scale testing
    # with open("../dataset.csv",'wb') as f3:
        
        reader = csv.reader(f2)
        writer = csv.writer(f3) 
        
        # write header for new dataset
        # start1 = timeit.timeit()
        writer.writerow(next(reader) + [m for m in keywords])
        # end1 = timeit.timeit()
        # print "time to read header (once): " + str(end1-start1)


        # start3 = timeit.timeit()
        # for each row, check for presence of keywords and add new dataset fields
        for i,row in enumerate(reader):
            if (i+1) % 1000 == 0:
                print "Reading wine #" + str(i+1)
            kwpresent = [0]*len(keywords)
            for m,word in enumerate(keywords):
                # check if keyword is in review (mostly case-insensitive)
                if word in (row[reviewcol]).upper().lower():
                    kwpresent[m] = 1
            writer.writerow(row + [m for m in kwpresent])
        # end3 = timeit.timeit()
        # print "time to write dataset (once): " + str(end3-start3)




