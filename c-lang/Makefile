CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -g
TARGET = game
SRCDIR = src/game
SOURCES = $(SRCDIR)/main.c $(SRCDIR)/metodos.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: 
	cd src && ./run.sh game

play: run

debug: CFLAGS += -DDEBUG
debug: $(TARGET)

clean:
	rm -f $(TARGET) $(OBJECTS)
	rm -f $(SRCDIR)/main

rebuild: clean all

memcheck: $(TARGET)
	valgrind --leak-check=full --show-leak-kinds=all ./$(TARGET)

help:
	@echo "all       - Compila o jogo"
	@echo "run       - Executa o jogo usando run.sh"
	@echo "play      - Executa o jogo usando run.sh"
	@echo "debug     - Compila com flags de debug"
	@echo "clean     - Remove arquivos compilados"
	@echo "rebuild   - Limpa e recompila"
	@echo "memcheck  - Verifica vazamentos de memória"
	@echo "help      - Mostra esta ajuda"

.PHONY: all run play debug clean rebuild memcheck help