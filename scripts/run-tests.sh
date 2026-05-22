#!/usr/bin/env bash
# Simple curl-based smoke tests for Unix-like environments
# Usage: start the API, then: bash scripts/run-tests.sh

BASE="http://localhost:5000"

echo "POST invalid (start=today)"
curl -s -X POST "$BASE/api/berlesek" -H "Content-Type: application/json" -d '{"uid":1,"chefId":10,"startDate":"'$(date +%F)'","endDate":"'$(date -d "+3 days" +%F)'","dailyRate":100,"baseFee":20}'
echo

echo "GET all"
curl -s "$BASE/api/berlesek"
echo
