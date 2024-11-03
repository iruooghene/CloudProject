#!/bin/bash
for i in {1..}; do
  curl -s -f http://127.0.0.1:8088/fibonacci/900000

done

# Wait for all background processes to finish
wait
