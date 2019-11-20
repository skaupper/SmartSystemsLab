APP_NAME=hdc1000

CPPFLAGS=-Wall -Werror -pedantic -std=c++17 -O2
# Attention: the lib diretory where the MQTT is installed into may not be in the LD path!
LDFLAGS=-L/usr/local/lib64 -lpaho-mqtt3as -lpaho-mqttpp3

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
	scp $(APP_NAME)  $(DEPLOYSSH):$(DEPLOYSSHPATH)/$(APP_NAME)
	ssh $(DEPLOYSSH) $(DEPLOYSSHPATH)/$(APP_NAME)


.PHONY: all clean deploy
