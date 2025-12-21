# DDD-Policies-Project

## Introduction
I'm interested in how domain-driven design (DDD) policies can be used to centralize business logic in full-stack applications. 
To explore this concept I've developed an Android app with a user administration domain. 
The end result could serve as a practical example of DDD-policies being used to define and enforce business logic.

## Description
The project is organized as a Melos monorepo and includes a simplistic Flutter client using BLoC for state management, with extensive BLoC and integration test coverage. 
The server was built with Shelf, using in-memory databases with controller level API testing. 
The project also includes a shared domain package which was fully unit tested. Other packages include utilities for API management, mapping and testing.

Some advanced features were included, such as policy based user action authorization and credential validation.

By working on this project I've learned more about the challenges and potential benefits involved building a system with policy based business logic.

## UI Examples
<p align="center">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/analyst_denied_by_delete_user_policy.png?raw=true" width="200">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/user_denied_by_delete_user_policy.png?raw=true" width="200">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/user_denied_by_update_email_policy.png?raw=true" width="200">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/user_denied_by_update_password_policy.png?raw=true" width="200">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/user_denied_by_email_policy.png?raw=true" width="200">
  <img src="https://github.com/JohanMarcolin/DDD-Policies-Project/blob/master/images/user_denied_by_password_policy.png?raw=true" width="200">
</p>

## Project Structure
```
apps/
	client/         # Flutter Android app
	server/         # Shelf backend
packages/
	domain/         # Shared entities, services and policies etc
	api_error_codes/# API error codes and base exceptions
	http_api/       # HTTP API client utility
	test_utils/     # Test fixtures, runners, mocks, server utilities
	mappers/        # Entity mappers
```

## How to Run Locally

1. **Clone the project**
	```sh
	git clone https://github.com/JohanMarcolin/DDD-Policies-Project.git
	```

2. **Set up your development device**
	- For Android: Install [Android Studio](https://developer.android.com/studio) and set up an emulator. Follow the official [Flutter Android setup guide](https://docs.flutter.dev/get-started/install/windows#android-setup).

3. **Install dependencies for all packages/apps**
	```sh
	melos bootstrap
	```

4. **Build the required env configuration for all packages/apps**
	```sh
	melos run env_build
	```

5. **Start the server**
	```sh
	dart run apps/server/lib/application/main.dart
	```

6. **Start the client**
Manually run the client's main.dart or setup a launch.json file.

7. **Login to a test account**
	 ```
	 User account:
	 { email: "user1", password: "user1" }

	 Admin account:
	 { email: "admin1", password: "admin1" }

	 Analyst account:
	 { email: "analyst1", password: "analyst" }
	 ```

**Run tests**
	 - **Server tests:**
		 ```sh
		 melos run server_api_test
		 ```
	 - **Client integration tests:**
		 ```sh
		 melos run client_integration_test
		 ```
	 - **Domain unit tests:**
		 ```sh
		 melos run domain_unit_test
		 ```