APP_NAME=event_sensors

# DEFINES=NO_SENSORS
CPPFLAGS=-Wall -Werror -pedantic -std=c++17 -O2 -g -Wno-psabi $(addprefix -D,$(DEFINES))
# Attention: the lib diretory where the MQTT is installed into may not be in the LD path!
LDFLAGS=-lpaho-mqtt3as -lpaho-mqttpp3 -lfpgaregion -lpthread -lz

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
