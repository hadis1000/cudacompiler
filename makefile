CC := g++ # This is the main compiler
# CC := clang --analyze # and comment out the linker last line for sanity
LINTER := cpplint
FORMATER := clang-format
MKDIR_P = mkdir -p

SRCDIR := src
LIBDIR := include
TESTDIR := test
BUILDDIR := build
EXAMPLEDIR := examples
TARGET := bin/runner
TESTTARGET := bin/tester
DIRS := bin build $(LIBDIR)/catch2
 
SRCEXT := cpp
HEADDEREXT := hpp
SOURCES := $(shell find $(SRCDIR) -type f -name '*.$(SRCEXT)')
TESTS := $(shell find $(TESTDIR) -type f -name '*.$(SRCEXT)')
EXAMPLES := $(shell find $(EXAMPLEDIR) -type f -name '*.$(SRCEXT)')
HEADERS := $(shell find $(LIBDIR) -type f -name '*.$(HEADDEREXT)')
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
TEST_OBJ = $(OBJECTS) $(patsubst $(TESTDIR)/%,$(BUILDDIR)/%,$(TESTS:.$(SRCEXT)=.o))
CFLAGS := -std=c++17 -Wall -g -DNVRTC_GET_TYPE_NAME=1
LIB := -lnvrtc -lcuda -L $(CUDA_PATH)/lib64 -Wl,-rpath,$(CUDA_PATH)/lib64 
INC := -I $(LIBDIR) -I $(CUDA_PATH)/include

# Build
example_program: example
	@echo " $(CC) build/example_program.o $(OBJECTS) -o $(TARGET) $(LIB)"; $(CC) build/example_program.o $(OBJECTS) -o $(TARGET) $(LIB)
example_template: example
	echo " $(CC) build/example_template.o $(OBJECTS) -o $(TARGET) $(LIB)"; $(CC) build/example_template.o $(OBJECTS) -o $(TARGET) $(LIB)
example_saxpy: example
	@echo " $(CC) build/example_saxpy.o $(OBJECTS) -o $(TARGET) $(LIB)"; $(CC) build/example_saxpy.o $(OBJECTS) -o $(TARGET) $(LIB)
example: directories $(OBJECTS)
	+$(MAKE) -C examples

directories: ${DIRS}

${DIRS}:
	${MKDIR_P} ${DIRS}

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGET)

# Format
format:
	$(FORMATER) -i -style=file $(SOURCES) $(HEADERS) $(TESTS) $(EXAMPLES)

# Linter
lint:
	$(LINTER) --root=${CURDIR} --recursive .
	#clang-tidy src/ -system-headers=false

# Tests
build_tests: directories $(OBJECTS)
	@wget -nc -P $(LIBDIR)/catch2 https://raw.githubusercontent.com/catchorg/Catch2/master/single_include/catch2/catch.hpp
	+$(MAKE) -C test
check: build_tests
	@echo " Linking... $(TEST_OBJ)";
	@echo " $(CC) $(TEST_OBJ) -o $(TESTTARGET) $(LIB)"; $(CC) $(TEST_OBJ) -o $(TESTTARGET) $(LIB)
	@./bin/tester -d yes

.PHONY: clean, lint, directories, format 
