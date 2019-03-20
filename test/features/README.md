To set the log level to debug
behave -D log_level=DEBUG --no-capture aws.feature

To disable docker-compose up and down use: 
behave -D DISABLE_DOCKER_UP DISABLE_DOCKER_DOWN aws.feature

# Need to change to the directory where your local Behave is installed 
# and run the following command
# Tested with behave 1.2.6
cd /usr/local/lib/python3.6/site-packages/behave/
patch -p1 < ~/Source/shib-in-a-box/test/behave.patch
rm -r __pycache__

# To run the regression test with Behave, clone test-behave-core repo 
# and pip install -e your-test-behave-core-dir.
