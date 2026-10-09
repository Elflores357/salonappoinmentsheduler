#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
echo

show_services() {
  psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

show_services
read SERVICE_ID_SELECTED

while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]] || [[ -z $(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;") ]]; do
  echo -e "\nI could not find that service. What would you like today?"
  show_services
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_PHONE_SQL=${CUSTOMER_PHONE//\'/\'\'}
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL';")

if [[ -z "$CUSTOMER_ID" ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=${CUSTOMER_NAME//\'/\'\'}
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -q -t -A -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME_SQL', '$CUSTOMER_PHONE_SQL') RETURNING customer_id;")
else
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
SERVICE_TIME_SQL=${SERVICE_TIME//\'/\'\'}
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL');" > /dev/null

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."