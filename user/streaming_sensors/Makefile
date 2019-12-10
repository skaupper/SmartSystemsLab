APP_NAME=streaming_sensors

CPPFLAGS=-Wall -Werror -pedantic -std=c++17 -O2 -g -Wno-psabi
# Attention: the lib diretory where the MQTT is installed into may not be in the LD path!
LDFLAGS=-lpaho-mqtt3a -lpaho-mqttpp3 -lfpgaregion -lpthread

SOURCES=$(wildcard *.cpp)
OBJECTS=$(SOURCES:.cpp=.o)


all: $(APP_NAME)

$(APP_NAME): $(OBJECTS)
	$(CXX)  $^ $(LDFLAGS) -o $@

%.o: %.cpp
	$(CXX) -c $< $(CPPFLAGS) -o $@

clean:
	rm -rf $(OBJECTS)
	rm -rf $(APP_NAME)

deploy: all
	scp $(APP_NAME)  $(DEPLOYSSH):$(DEPLOYSSHPATH)/$(APP_NAME)
	ssh $(DEPLOYSSH) $(DEPLOYSSHPATH)/$(APP_NAME)


.PHONY: all clean deploy
