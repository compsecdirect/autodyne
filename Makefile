.PHONY: all build start stop test logs clean

all:

build:
        docker build -t autodyne .

start:
        docker-compose up -d

stop:
        docker-compose down

logs:
        docker-compose logs

test:
        docker run --privileged -v $(CURDIR)/samples/:/opt/firmadyne/samples -v $(CURDIR)/samples-out/:/opt/firmadyne/samples-out -dit autodyne /opt/firmadyne/autodyne-0.5a.sh Bar 1.bin

clean:
        @echo "nothing to be done"

