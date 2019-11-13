APP_NAME=show_ip

CPPFLAGS=-Wall -Werror -pedantic -std=c++17
LDFLAGS=

SOURCES=$(wildcard *.cpp)
OBJECTS=$(SOURCES:.cpp=.o)


all: $(APP_NAME)

$(APP_NAME): $(OBJECTS)
	$(CXX) $(LDFLAGS) $< -o $@

%.o: %.cpp
	$(CXX) $(CPPFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJECTS)
	rm -rf $(APP_NAME)

deploy: all
	scp $(APP_NAME)  $(DEPLOYSSH):$(DEPLOYSSHPATH)/$(APPNAME)
	ssh $(DEPLOYSSH) $(DEPLOYSSHPATH)/$(APPNAME)


.PHONY: all clean
