/*
To compile on Mac:
    g++ -Wall -Wconversion -Wextra buildDictionaryForBook.cpp -o buildDictionaryForBook
To run on Mac:
    ./buildDictionaryForBook
*/

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <unordered_map>

// define the maximum number of words to output
#define maxToOutput 10000


bool comp(std::pair<std::string, int> a, std::pair<std::string, int> b) {
  return std::get<1>(a) > std::get<1>(b);
}

int main() {
  std::unordered_map<std::string, int> wordCount;


  std::ifstream file;
  std::ofstream outFile;
  outFile.open("../frequenciesBook.txt");
  file.open("../book.txt");
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


        std::istringstream iss(line);
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
