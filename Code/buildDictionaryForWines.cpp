/*
To compile on Mac:
    g++ -Wall -Wconversion -Wextra buildDictionaryForWines.cpp -o buildDictionaryForWines
To run on Mac:
    ./buildDictionaryForWines
*/

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <unordered_map>

// defint the maximum number of lines to parse
#define maxToParse 1000000000 // 1000000000
// define the maximum number of words to output
#define maxToOutput 10000


bool comp(std::pair<std::string, int> a, std::pair<std::string, int> b) {
  return std::get<1>(a) > std::get<1>(b);
}

int main() {
  std::unordered_map<std::string, int> wordCount;


  std::ifstream file;
  std::ofstream outFile;
  outFile.open("../frequencies.txt");
  file.open("../wine.csv");
  if (!file) {
        std::cout << "Unable to open file";
        exit(1); // terminate with error
    }

    int num = 0;
    std::string line;
    while (std::getline(file, line)) {
        if (num == 0) {
          ++num;
          continue;
        }
        // Process str
        std::string description;

        char* ch1 = std::strtok (&line[0u], "\"");
        int counter = 0;
        while (ch1 != NULL) {
          if (counter == 1) {
            description = ("%s\n",ch1);
            //printf ("%s\n",ch1);
            break;
          }
          ch1 = strtok (NULL, "\"");
          ++counter;
        }

        //std::cout << description << std::endl;

        std::istringstream iss(description);
        for(std::string s; iss >> s; ) {
          // lower case
          std::transform(s.begin(), s.end(), s.begin(), ::tolower);
          // remove punctuation
          s.erase (std::remove_if(s.begin (), s.end (), ispunct), s.end ());
          // remove whitespace (strip)
          s.erase(remove_if(s.begin(), s.end(), isspace), s.end());

          if (wordCount.find(s) == wordCount.end()) {
            //std::cout << s << " not found" << std::endl;
            wordCount[s] = 1;
          } else {
            //std::cout << "Found " << s << std::endl;
            wordCount[s] += 1;
          }

        }


        ++num;
        if (num == maxToParse) { break; }
    }




    // sort the vector
    std::vector<std::pair<std::string, int> > elems(wordCount.begin(), wordCount.end());
    std::sort(elems.begin(), elems.end(), comp);

    int numWrote = 0;
    for (auto it : elems) {
      outFile << std::get<0>(it) << ":" << std::get<1>(it) << std::endl;
      ++numWrote;
      if (numWrote == maxToOutput) { break; }
    }

    file.close();
    outFile.close();

    std::cout << "Wrote to file!" <<std::endl;
    std::cout << "Lines Parsed: " << num << std::endl;
    std::cout << "Lines wrote: " << numWrote << std::endl;
  return 0;
}
