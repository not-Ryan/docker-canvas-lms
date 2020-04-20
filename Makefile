BACKUP_SLUG := backups/backup_$(shell date +"%Y-%b-%d_%H:%M")
BACKUP ?= backup
STACK ?= canvas-lms

logbackup:
	@echo $(DATE)
	@echo $(BACKUP_SLUG)
	@echo $(BACKUP)

restart:
	docker-compose -p $(STACK) restart

start:
	docker-compose -p $(STACK) up -d

backup:
	docker-compose -p $(STACK) stop
	sudo tar -C /var/lib/docker/volumes/$(STACK)_pg_data/ -cf ./$(BACKUP_SLUG) _data
	@echo Created a backup to $(BACKUP_SLUG)
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
	make implement_custom
	docker run --rm instructure/canvas-lms:master cat Gemfile.lock > Gemfile.lock
	docker run --rm instructure/canvas-lms:master cat yarn.lock > yarn.lock
	docker-compose -p $(STACK) run --rm web bash -c "bundle; bundle exec rake db:create db:initial_setup"

from_backup:
	docker-compose -p $(STACK) pull web
	make implement_custom
	docker run --rm instructure/canvas-lms:master cat Gemfile.lock > Gemfile.lock
	docker run --rm instructure/canvas-lms:master cat yarn.lock > yarn.lock
	docker-compose -p $(STACK) run --rm web bash -c "bundle; bundle exec rake db:create"
	make restore

recreate: clean create

implement_custom: 
	@echo Implementing custom files...
	docker cp customs/login.html.erb $(STACK)_web_1:/usr/src/app/app/views/login/canvas/_new_login_content.html.erb