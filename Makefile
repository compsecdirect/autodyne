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
		docker run --privileged -v $(CURDIR)/samples/:/opt/firmadyne/samples -v $(CURDIR)/sample_output/:/opt/firmadyne/sample-out -dit autodyne /opt/firmadyne/autodyne-0.6.sh Bar 1.bin

clean:
		@echo "nothing to be done"

