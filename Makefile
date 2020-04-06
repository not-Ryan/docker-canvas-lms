DATE := $(date +"%Y-%b-%d_%H:%M")
BACKUP := backup_$(date +"%Y-%b-%d_%H:%M")
STACK ?= canvas-lms

logbackup:
	@echo $(DATE)
	@echo $(BACKUP)

restart:
	docker-compose -p $(STACK) restart

start:
	docker-compose -p $(STACK) up -d

backup:
	docker-compose -p $(STACK) stop
	sudo tar -C /var/lib/docker/volumes/$(STACK)_pg_data/ -cf ./$(BACKUP) _data
	@echo Created a backup to $(BACKUP)
	docker-compose -p $(STACK) up -d

restore:
	docker-compose -p $(STACK) stop
	sudo rm -rf /var/lib/docker/volumes/$(STACK)_pg_data/_data
	sudo tar -C /var/lib/docker/volumes/$(STACK)_pg_data/ -xf $(BACKUP)
	@echo Restored a backup from $(BACKUP)
	docker-compose -p $(STACK) up -d

clean:
	docker-compose -p $(STACK) down --volumes

create:
	docker-compose -p $(STACK) pull web
	docker run --rm instructure/canvas-lms:master cat Gemfile.lock > Gemfile.lock
	docker run --rm instructure/canvas-lms:master cat yarn.lock > yarn.lock
	docker-compose -p $(STACK) run --rm web bash -c "bundle; bundle exec rake db:create db:initial_setup"

recreate: clean create
