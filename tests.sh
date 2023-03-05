echo "Unit testing JMS Exporter..."
if diff -q test/models/expected.jms build/test/models/test.jms; then
    echo "\033[0;32mOK.\033[0m"
    exit 0
else
    echo "\033[0;31mFAILED.\033[0m"
    exit 1
fi