# Flight Manager Application

Welcome to the Flight Manager Application! This application allows you to manage customers, airplanes, flights, and reservations for an airline company. Below is an overview of the features and functionalities provided by the application.

## Features

### Customer List Page

This page allows you to manage a database of customers. You can add new customers, view existing customers, update customer details, and delete customers.

- **Add Customer**: A button to add a new customer. When pressed, it navigates to a page where you can enter the customer's first and last name, address, and birthday. All fields must be filled before submission.
- **View Customer**: A list of all customers. Selecting a customer displays their details on the same page where they were created.
- **Update Customer**: An option to update the details of an existing customer.
- **Delete Customer**: An option to remove a customer from the list and the database.
- **Copy Previous Customer Data**: When adding a new customer, you can choose to copy the fields from the previously created customer or start with a blank page. Uses EncryptedSharedPreferences to save the data from the previously created customer.

### Airplane List Page

This page simulates an airline's list of airplanes. You can add new airplanes, view existing airplanes, and delete airplanes that are no longer in service.

- **Add Airplane**: A button to add a new airplane. When pressed, it navigates to a page where you can enter the airplane type (e.g., Airbus A350, Boeing 777), the number of passengers, maximum speed, and range. All fields must be filled before submission.
- **View Airplane**: A list of all airplanes. Selecting an airplane displays its details on the same page where it was created.
- **Update Airplane**: An option to update the details of an existing airplane.
- **Delete Airplane**: An option to remove an airplane from the list and the database.

### Flights List Page

This page simulates an airline's list of flights between two cities. You can add new flights, view existing flights, and delete flights that are no longer offered.

- **Add Flight**: A button to add a new flight. When pressed, it navigates to a page where you can enter the departure and destination cities, departure time, and arrival time. All fields must be filled before submission.
- **View Flight**: A list of all flights. Selecting a flight displays its details on the same page where it was created.
- **Update Flight**: An option to update the details of an existing flight.
- **Delete Flight**: An option to remove a flight from the list and the database.

### Reservation Page

This page simulates booking a customer on a flight. You can add new reservations for customers on given flights.

- **Add Reservation**: A button to add a new reservation. When pressed, it navigates to a page where you can select an existing customer for an existing flight on a certain day. Each flight happens once per day and repeats every day.
- **View Reservation**: A list of all reservations made with the company. Selecting a reservation displays its details, including customer name, departure and destination cities, and departure and arrival times.

## How to Run

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/your-username/flight_manager.git
   cd flight_manager
   ```

2. **Install Dependencies**:
   ```sh
   flutter pub get
   ```

3. **Run the Application**:
   ```sh
   flutter run
   ```

## Technologies Used

- Flutter
- Dart
- SQLite (via `floor` package for database management)
- EncryptedSharedPreferences for securely storing temporary data

## Contributors

This project was created by:
[http](https://github.com/andreavisani)
https://github.com/AnnLoYiAn
https://github.com/DikchhaR
https://github.com/himanishrishi7

## License

This project is licensed under the MIT License - see the LICENSE file for details.


Enjoy using the Flight Manager Application!
