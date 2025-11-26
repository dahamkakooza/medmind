#!/bin/bash

# MedMind Test Coverage Script
# This script runs tests with coverage and generates an HTML report

echo "🧪 Running MedMind Test Suite with Coverage..."
echo ""

# Run tests with coverage
flutter test --coverage

# Check if tests passed
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Tests failed. Please fix failing tests before generating coverage report."
    exit 1
fi

echo ""
echo "✅ All tests passed!"
echo ""

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "⚠️  lcov is not installed. Coverage report will not be generated."
    echo "   Install lcov:"
    echo "   - macOS: brew install lcov"
    echo "   - Linux: sudo apt-get install lcov"
    echo ""
    echo "Coverage data saved to: coverage/lcov.info"
    exit 0
fi

# Generate HTML report
echo "📊 Generating HTML coverage report..."
genhtml coverage/lcov.info -o coverage/html --quiet

echo ""
echo "✅ Coverage report generated!"
echo ""
echo "📈 Coverage Summary:"
lcov --summary coverage/lcov.info

echo ""
echo "🌐 Open coverage report:"
echo "   open coverage/html/index.html"
echo ""
