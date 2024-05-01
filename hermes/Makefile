CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17

INCLUDE_PATHS = -I./inc

LIBRARY_PATHS = 

LIBRARIES = -pthread

SOURCES = main.cpp hermes.cpp util/misc.cpp util/stats.cpp util/initial.cpp util/feat_hash.cpp

TARGET = main

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(LIBRARIES) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)