import collections

# the top "n" different words from book that we wish to remove from wines
n = 10000
wineWords = []
bookWords = []

with open("../frequenciesWines.txt") as f1:
    with open("../frequenciesBook.txt") as f2:

        for line in f1:
            line = line.strip()
            wineWords.append((line.split(":")[0], int(line.split(":")[1])))
            #wineWords.append(line.split(":")[0])
        for line in f2:
            line = line.strip()
            #bookWords.append((line.split(":")[0], int(line.split(":")[1])))
            bookWords.append(line.split(":")[0])

with open("../mergedFrequencies.txt", "w") as f:
    getRidOf = bookWords[0:n]
    for word in wineWords:
        if word[0] not in getRidOf:
            f.write(word[0]+":"+str(word[1])+"\n")
