TARGET = cudafractal
LIBS = -lglut -lgd
CC = nvcc
CFLAGS = -g -G

.PHONY: default all clean

default: $(TARGET)
all: default

OBJECTS = $(patsubst %.cu, %.o, $(wildcard *.cu))
HEADERS = $(wildcard *.h)

%.o: %.cu $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) $(LIBS) -o $@

clean:
	    -rm -f *.o
		-rm -f $(TARGET)
