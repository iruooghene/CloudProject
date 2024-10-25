#!/bin/bash
for i in {1..50}; do
  curl -s http://localhost:8088/fibonacci?n=1 &
done

# Wait for all background processes to finish
wait
