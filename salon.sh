#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Menampilkan daftar layanan
SHOW_SERVICES() {
  while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    SERVICE_ID=$(echo "$SERVICE_ID" | xargs)
    SERVICE_NAME=$(echo "$SERVICE_NAME" | xargs)
    echo "$SERVICE_ID) $SERVICE_NAME"
  done < <(echo "SELECT service_id, name FROM services ORDER BY service_id;" | psql -X --username=freecodecamp --dbname=salon -t)
}

# Menampilkan daftar layanan pertama kali
SHOW_SERVICES

# Meminta pilihan layanan
read SERVICE_ID_SELECTED

# Memeriksa apakah layanan tersedia
while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $(echo "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | psql -X --username=freecodecamp --dbname=salon -t) ]]
do
  SHOW_SERVICES
  read SERVICE_ID_SELECTED
done

# Meminta nomor telepon
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Memeriksa apakah pelanggan sudah terdaftar
CUSTOMER_NAME=$(echo "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';" | psql -X --username=freecodecamp --dbname=salon -t | xargs)

# Jika pelanggan baru
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$(echo "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" | psql -X --username=freecodecamp --dbname=salon)
fi

# Meminta waktu layanan
echo -e "\nWhat time would you like your cut?"
read SERVICE_TIME

# Mendapatkan customer_id
CUSTOMER_ID=$(echo "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | psql -X --username=freecodecamp --dbname=salon -t | xargs)

# Mendapatkan nama layanan
SERVICE_NAME=$(echo "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | psql -X --username=freecodecamp --dbname=salon -t | xargs)

# Menyimpan appointment
INSERT_APPOINTMENT_RESULT=$(echo "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" | psql -X --username=freecodecamp --dbname=salon)

# Menampilkan konfirmasi
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."