default: ssh

ssh:
	ssh root@ssh.sandradodd.com

build:
	bundle exec jekyll build --incremental

start:
	bundle exec jekyll serve --incremental

s: start

# Group: https://groups.yahoo.com/api/v1/groups/AlwaysLearning/
# Topics: https://groups.yahoo.com/api/v1/groups/AlwaysLearning/topics?count=100
# Photos: https://groups.yahoo.com/api/v1/groups/AlwaysLearning/photos
# Links: https://groups.yahoo.com/api/v1/groups/AlwaysLearning/links
# API docs: https://www.archiveteam.org/index.php?title=Yahoo!_Groups

.ONESHELL:

posts:
	rvm `cat .ruby-version` do ruby create-posts.rb



cache:
	rvm `cat .ruby-version` do ruby downloader.rb
.PHONY: cache

clean:
	rm -vf \
		cache/topics.json \
		cache/topic-`jq .ygData.lastTopic cache/topics.json`.json

stats:
	@jq '.ygData.numTopics' topics.json
	@ls -1 topic-*.json | wc -l
	@du -shc topic-*.json | tail -1

edit:
	code -n .

e: edit

include .env
upload:
	lftp -u gurdiga@sandradodd.com ftp.sandradodd.com \
		--password $(LFTP_PASSWORD) \
		-e '\
			mirror --delete --reverse --parallel=5 --continue _site archive/AlwaysLearning; \
			quit \
		'

copy: download rsync relative-links feedburner charset encoding

ftp:
	time lftp -u gurdiga@sandradodd.com ftp.sandradodd.com \
		--password $(LFTP_PASSWORD)

download:
	time lftp -u gurdiga@sandradodd.com ftp.sandradodd.com \
		--password $(LFTP_PASSWORD) \
		-e "mirror \
				--continue \
				--parallel=5 \
				--exclude-glob=archive/* \
				--exclude-glob=logs/* \
				. site; \
			quit \
		"
rsync:
	time rsync -az site root@ssh.sandradodd.com:/var/www/

misc-fixes:
	mv /var/www/site/plants/falseseaonion.jpg /var/www/site/plants/falseseaonion.html
	mv /var/www/site/animals/dogsandcats /var/www/site/animals/dogsandcats.html

relative-links:
	time ssh root@ssh.sandradodd.com "\
		find /var/www/site/ -type f -name '*.htm*' | xargs \
			sed -i --regexp-extended -e 's|http://(www\.)?sandradodd\.com/|/|ig' \
	"
	# time ssh root@ssh.sandradodd.com "\
		find /var/www/site/ -type f -name '*.html' | xargs \
			sed -i --regexp-extended -e 's|http://(www\.)?sandradodd\.com|https://sd\.homeschooling\.md|ig' \
	"
feedburner:
	time ssh root@ssh.sandradodd.com "\
		sed -i --regexp-extended -e 's|http://feeds\.feedburner\.com|https://feeds\.feedburner\.com|g' /var/www/site/index.html \
	"

charset:
	time ssh root@ssh.sandradodd.com "\
		sed -i --regexp-extended -e 's|charset=windows-1252|charset=utf-8|g' /var/www/site/sca/atenveldt/lockehavenHistory.html \
	"
	time ssh root@ssh.sandradodd.com "\
		find /var/www/site/ -type f -name '*.htm*' | xargs \
			sed -i -e 's|charset=iso-8859-1|charset=utf-8|ig' \
	"

encoding:
	time ssh root@ssh.sandradodd.com '\
		find /var/www/site/ -type f -name "*.htm*" | while read file; do \
			encoding=`uchardet $$file`; \
			if (( encoding != "UTF-8" && encoding != "ASCII" )); then \
				echo "> $$file: $$encoding"; \
				recode $$encoding...utf8 $$file; \
				echo "< $$file: `uchardet $$file`"; \
			fi; \
		done \
	'
