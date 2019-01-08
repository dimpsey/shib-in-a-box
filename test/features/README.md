To set the log level to debug
behave -D log_level=DEBUG --no-capture aws.feature

To disable docker-compose up and down use: 
behave -D DISABLE_DOCKER_UP DISABLE_DOCKER_DOWN aws.feature
