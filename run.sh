#!/bin/bash

# Start Dart server in the background
dart run server/application/main.dart &

# Start Flutter client in the background
cd client && flutter run &

# Wait for both to finish (keeps script running)
wait