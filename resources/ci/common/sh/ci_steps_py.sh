py --version
py -m pip install --upgrade pip
py -m pip install -r "./resources/app/meta/manifests/pip_requirements.txt"
mkdir ./failures
echo "" > ./failures/errors.txt
py -m resources.tests.items
py -m resources.tests.functions
py -m resources.tests.locations
py -m resources.tests.asserts.validate

echo "ERRORS:"
cat ./failures/errors.txt
