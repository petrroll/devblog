serve:
	bundle exec jekyll serve --drafts --watch

install:
	bundle install

build:
	bundle exec jekyll build

updateGemLock:
	bundle update 

prereqs:
	apt-get install ruby ruby-dev zlib1g-dev
	gem install bundler