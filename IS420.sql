drop table customer cascade constraints;
drop table message cascade constraints;
drop table parking_zone cascade constraints;
drop table vehicle cascade constraints;
drop table parking_session cascade constraints;
drop table parking_payment cascade constraints;

create table customer (
cid int,
CFirst_name varchar(20),
CLast_name varchar(20),
CAddress varchar (50),
Czip number (5),
Cstate varchar(2),
Cemail varchar(50),
Cphone varchar(13),
cardnum varchar (25),
constraint cid_PK Primary Key(cid)); 

INSERT INTO customer VALUES (1111, 'John', 'Smith', '123 Baltimore Rd', 21230, 'MD', 'johnsmith@gmail.com', '111-111-1111', '1111-1111-1111-1111');
INSERT INTO customer VALUES (2222, 'Mary', 'Mack', '123 Maryland Rd', 21229, 'MD', 'mary@gmail.com', '222-222-2222', '2222-2222-2222-2222');
INSERT INTO customer VALUES (3333, 'Jane', 'Doe', '123 Old Town Rd', 21673, 'VA', 'jane@gmail.com', '333-333-3333', '3333-3333-3333-3333');

create table message(
mid int,
cid int,
message_time timestamp,
body varchar(100),
CONSTRAINT MID_PK PRIMARY KEY (MID),
CONSTRAINT CID_FK1 FOREIGN KEY (CID) REFERENCES customer(CID));

INSERT INTO message VALUES (123, 1111, timestamp '2023-10-4 13:30:00', 'Session 123 ends at 02:30');
INSERT INTO message VALUES (456, 2222, timestamp '2023-10-4 14:30:00', 'Session 123 ends at 02:30');
INSERT INTO message VALUES (789, 3333, timestamp '2023-10-4 15:30:00', 'Session 123 ends at 02:30');

CREATE TABLE parking_zone ( 
ZID int,          
Zaddress varchar(50),   
Zzip number(5),    
Zstate char(2),       
capacity int,          
open_spots int,         
hourly_rate decimal(5,2),   
max int,         
effective_start timestamp,     
effective_end timestamp,     
start_day int,           
end_day int,           
CONSTRAINT ZID_PK PRIMARY KEY(ZID));

INSERT INTO parking_zone VALUES (1000, '52 Lewis Rd', 21045, 'MD', 200, 10, 2.00, 5, timestamp '2023-10-4 15:30:00', timestamp '2023-10-4 17:30:00', 1, 5);
INSERT INTO parking_zone VALUES (2000, '105 Hard Ct', 21260, 'MD', 300, 15, 3.00, 12, timestamp '2023-10-4 16:30:00', timestamp '2023-10-4 18:30:00', 1, 7);
INSERT INTO parking_zone VALUES (3000, '1 New Rd', 21230, 'MD', 400, 20, 4.00, 24, timestamp '2023-10-4 17:30:00', timestamp '2023-10-4 19:30:00', 2, 4);

CREATE TABLE vehicle ( 
VID int,
CID int,
plate_number varchar(7),       
state char(2),         
maker varchar(20),      
model varchar(20),     
year number(4),         
color varchar(20),      
CONSTRAINT VID_PK PRIMARY KEY (VID),
CONSTRAINT CID_FK2 FOREIGN KEY (CID) REFERENCES customer(CID));

INSERT INTO vehicle VALUES (9999, 1111, 'DC12345', 'DC', 'Honda', 'Accord', 2017, 'Silver');
INSERT INTO vehicle VALUES (8888, 2222, 'GL58431', 'MD', 'Toyota', 'Rav 4', 2020, 'Black');
INSERT INTO vehicle VALUES (7777, 3333, 'MM37292', 'MD', 'Subaru', 'Impreza', 2022, 'Blue');

CREATE TABLE parking_session ( 
PID int,        
CID int,
VID int,      
ZID int,           
start_time timestamp,     
end_time timestamp,
max_session_time timestamp,     
total_charge decimal(6,2),
CONSTRAINT PID_PK PRIMARY KEY (PID),
CONSTRAINT CID_FK3 FOREIGN KEY (CID) REFERENCES customer(CID),
CONSTRAINT VID_FK4 FOREIGN KEY (VID) REFERENCES vehicle(VID),
CONSTRAINT ZID_FK5 FOREIGN KEY (ZID) REFERENCES parking_zone(ZID));

INSERT INTO parking_session VALUES (23979, 1111, 9999, 1000, timestamp '2023-10-04 15:30:00', timestamp '2023-10-04 18:30:00', timestamp '2023-10-04 20:30:00', 16.00);
INSERT INTO parking_session VALUES (57382, 2222, 8888, 2000, timestamp '2023-10-04 12:30:00', timestamp '2023-10-04 18:30:00', timestamp '2023-10-04 20:30:00', 20.00);
INSERT INTO parking_session VALUES (97874, 3333, 7777, 3000, timestamp '2023-10-04 10:30:00', timestamp '2023-10-04 16:30:00', timestamp '2023-10-04 20:30:00', 18.00);

CREATE TABLE parking_payment ( 
paymentID int,      
PID int,           
timepaid timestamp,        
price decimal(6,2),   
hours_paid int,          
CONSTRAINT paymentID_PK PRIMARY KEY (paymentID),
CONSTRAINT PID_FK6 FOREIGN KEY (PID) REFERENCES parking_session(PID));

INSERT INTO parking_payment VALUES (47289, 23979, timestamp '2023-10-4 18:30:00', 20.00, 4);
INSERT INTO parking_payment VALUES (37281, 57382, timestamp '2023-10-4 18:30:00', 22.00, 6);
INSERT INTO parking_payment VALUES (38110, 97874, timestamp '2023-10-4 16:30:00', 20.00, 8);


SET SERVEROUTPUT ON;


--Feature 5: Dang-Uy Nguyen
Set SERVEROUTPUT on;

CREATE OR REPLACE PROCEDURE feature5 (zoneID IN INTEGER, currentTime in timestamp) IS --Procedure created with zoneID and currentTime as inputs
    CURSOR c1 IS
SELECT v.VID, v.CID, v.plate_number, v.state, v.maker, v.model, v.color
FROM vehicle v, parking_session ps --SQL statement to join vehicle and parking session table with a currentTime between the start and end
WHERE v.VID = ps.VID AND currentTime < end_time AND currentTime > start_time AND ZID = zoneID;

v_id varchar(50); --declare values for cursor to print
c_id varchar(50);
plate varchar(7);
v_state char(2);
v_maker varchar(20);
v_model varchar(20);
v_color varchar(20);
i number := 0; 

BEGIN
    OPEN c1; 
        FETCH c1 INTO v_id, c_id, plate, v_state, v_maker, v_model, v_color;
        IF c1%notfound THEN --parking zone ID validation
            dbms_output.put_line('Incorrect zone ID');
        ELSE
        dbms_output.put_line('Here are the list of all vehicles with an active session in this parking zone:');
        dbms_output.put_line(' ');    
            LOOP --Loop to print car info
                i := i +1;
                dbms_output.put_line('Vehicle ID: ' || v_id);
                dbms_output.put_line('Customer ID: '|| c_id);
                dbms_output.put_line('License Plate: ' || plate);
                dbms_output.put_line('State: ' || v_state);
                dbms_output.put_line('Make: ' || v_maker);
                dbms_output.put_line('Model: ' || v_model);
                dbms_output.put_line('Color: ' || v_color);
                dbms_output.put_line(' ');
        
        FETCH c1 INTO v_id, c_id, plate, v_state, v_maker, v_model, v_color;
        EXIT WHEN c1%notfound;
            END LOOP;
        END IF;
    CLOSE c1;
END;
/

--Test case 1: valid parking zone ID input
EXEC feature5(1000, timestamp '2023-10-4 17:00:00'); --valid input
--Test case 2: invalid parking zone ID input
EXEC feature5(7, timestamp '2023-10-4 17:00:00'); --invalid parking ID input

--Feature 8: Dang-Uy Nguyen
SET SERVEROUTPUT ON;
DROP SEQUENCE MID_sequence;
CREATE SEQUENCE MID_sequence START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE Feature8(sessionID IN INTEGER, currentTime IN TIMESTAMP) IS
    valid_session INTEGER;
    session_cid INTEGER;
    endTime TIMESTAMP;

BEGIN
    SELECT COUNT(*), MAX(end_time), MAX(CID)
    INTO valid_session, endTime, session_cid
    FROM parking_session
    WHERE sessionID = PID;
    
IF valid_session = 0 THEN --checks if session ID exists
        DBMS_OUTPUT.PUT_LINE('Invalid session ID');
    
    ELSE
        IF endTime > currentTime THEN --checks if current time is BEFORE end time
            UPDATE parking_session SET end_time = currentTime WHERE sessionID = PID;

            INSERT INTO message (MID, CID, message_time, body)
            VALUES (MID_sequence.NEXTVAL, session_cid, currentTime, 'Session ' || sessionID || ' ends at ' || TO_CHAR(currentTime, 'YYYY-MM-DD HH24:MI:SS'));
            DBMS_OUTPUT.PUT_LINE('Session ' || sessionID || ' ends at ' || TO_CHAR(currentTime, 'YYYY-MM-DD HH24:MI:SS'));
        
        ELSE --condition if current time is AFTER end time
            INSERT INTO message (MID, CID, message_time, body)
            VALUES (MID_sequence.NEXTVAL, session_cid, currentTime, 'Session ' || sessionID || ' expired. You may get a ticket.');
            DBMS_OUTPUT.PUT_LINE('Session ' || sessionID || ' expired. You may get a ticket.');
        END IF;
    END IF;
END;
/

-- Test Case 1: Valid session ID and time
EXEC Feature8(23979, TO_TIMESTAMP('2023-10-04 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
--Test Case 2: Invalid session ID
EXEC Feature8(0, TO_TIMESTAMP('2023-10-04 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
--Test Case 3: Valid Session ID, but input time is later than end time
EXEC Feature8(57382, TO_TIMESTAMP('2023-10-04 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));


SELECT * FROM message;
SELECT * FROM parking_session;


--Feature 1: Zipporah
drop sequence create_new_customer; 
drop sequence customer_seq;

-- Create sequence to be called to the create_new_customer function
CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE create_new_customer (
  customerFname IN VARCHAR,
  customerLname IN VARCHAR,
  customer_address IN VARCHAR,
  customer_zip IN VARCHAR,
  customer_state IN VARCHAR,
  customer_email IN VARCHAR,
  customer_phoneNo IN VARCHAR,
  customer_credit_card IN VARCHAR
) AS
  v_customer_id NUMBER;
  v_count number;
BEGIN
  SELECT count (*) INTO v_count FROM customer WHERE Cphone = customer_phoneNo;
  
  -- If a customer with the same phone number exists, update their information
  IF v_count > 0 then
  UPDATE customer 
  SET
      CAddress = customer_address,
      Cstate = customer_state,
      Czip = customer_zip,
      Cemail = customer_email,
      cardnum= customer_credit_card
  WHERE Cphone = customer_phoneNo;
  SELECT cid into v_customer_id from customer where Cphone = customer_phoneNo;
        dbms_output.put_line('The user already exists.');
        dbms_output.put_line('Updated Address: ' || customer_address);
        dbms_output.put_line('Updated State: '|| customer_state);
        dbms_output.put_line('Updated Zip: ' ||  customer_zip);
        dbms_output.put_line('Updated Email:' || customer_email);
        dbms_output.put_line('Updated Credit Card Number:'|| customer_credit_card);
   Else 
     -- If no customer with the same phone exists, create a new customer
    SELECT customer_seq.NEXTVAL INTO v_customer_id FROM DUAL;
    INSERT INTO customer (cid, CFirst_name, CLast_name, CAddress, Cstate, Czip, Cemail, Cphone, cardnum)
    VALUES (v_customer_id, customerFname, customerLname, customer_address, customer_state, customer_zip, customer_zip, customer_phoneNo, customer_credit_card);
     dbms_output.put_line('New Customer ID: ' || v_customer_id);
 END IF;
END;

SELECT * FROM customer;

--Test Case 1 (Normal): Verification - This will create a new customer in the systems since there is no history of the phone number existing
exec create_new_customer ('Dave','Wilbur', '6979 Peapond Rd', 29877, 'NY', 'dwilbur@gmail.com', '443-990-6573', '3132-3473-2933-3543');

-- Test Case 2 (Special): Data Integrity - This will update the customers information since they exist in the system
exec create_new_customer  ('John', 'Smith', '293 Maes Court', 21784, 'MD', 'johnsmith@gmail.com', '111-111-1111', '1111-1111-1111-1111');

--Test Case 3 (Special): Verification - This will create a new customer in the system since there is no history of the phone number existing. This customer is in the same household and using the same card number as another customer, but will still be created as a new customer in the system
exec create_new_customer ('Brian','Feehan', '6979 Peapond Rd', 29877, 'NY', 'brian@gmail.com','410-549-6573', '3132-3473-2933-3543');



--Feature 2: Elizabeth
drop sequence vid_seq;
create sequence vid_seq START with 1000;

Create or replace procedure add_vehicle(v_cid in int, v_plate_number in varchar, v_state in char, v_maker in varchar, v_model in varchar, v_year in number, v_color in varchar)
 As	
 value_exists number;
BEGIN
 select count(*) into value_exists 
 from customer
 where cid = v_cid; 
 if value_exists = 0 then
  DBMS_OUTPUT.PUT_LINE('Invalid Customer ID');
 else 
  select count(*) into value_exists
  from vehicle
  where plate_number = v_plate_number and 
  state = v_state; 
  if value_exists != 0 then
   DBMS_OUTPUT.PUT_LINE('Vehicle already exists');
  else 
   insert into vehicle (vid, cid, plate_number, state, maker, model, year, color) values   
   (vid_seq.nextval, v_cid, v_plate_number, v_state, v_maker, v_model, v_year, 
   v_color);
  end if;
end if;
END;

--test case 1
set serveroutput on;
exec add_vehicle(1111, 'MD54321', 'MD', 'Toyota', 'Camry', 2010, 'Black'); -- valid input

Select * from vehicle;
--this will be inserted in the table because the CID id '1111' exists in the customer table and the plate number and state are unique from already existing vehicles.

test case 2
exec add_vehicle(1234, 'DC12345', 'DC', 'Honda', 'Accord', 2017, 'Silver'); -- invalid input

Select * from vehicle;
--this will not be inserted into the vehicle table because the customer id '1234' does not exist--resulting in the output displaying 'Invalid Customer ID'.




--Feature 4 Alex
Drop sequence ListCustomerParkingSessions;

CREATE OR REPLACE PROCEDURE ListCustomerParkingSessions (
    v_CID IN INT, 
    v_start_time IN TIMESTAMP, 
    v_end_time IN TIMESTAMP
) AS
    v_total_charge DECIMAL(6,2) := 0.00;
    v_count INT;
BEGIN
    -- Check if customer exists
    SELECT COUNT(*) INTO v_count FROM customer WHERE CID = v_CID;

    IF v_count = 0 THEN
        -- Customer does not exist
        DBMS_OUTPUT.PUT_LINE('No such customer.');
    ELSE
        -- Customer exists, list parking sessions
        FOR session_rec IN (
            SELECT PID, start_time, end_time, ZID, VID, total_charge 
            FROM parking_session
            WHERE CID = v_CID 
            AND start_time >= v_start_time 
            AND end_time <= v_end_time
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Session ID: ' || session_rec.PID || ', Start: ' || 
                TO_CHAR(session_rec.start_time, 'YYYY-MM-DD HH24:MI:SS') || ', End: ' || 
                TO_CHAR(session_rec.end_time, 'YYYY-MM-DD HH24:MI:SS') || ', Zone ID: ' || 
                session_rec.ZID || ', Vehicle ID: ' || session_rec.VID || ', Charge: ' || 
                session_rec.total_charge);
            v_total_charge := v_total_charge + session_rec.total_charge;
        END LOOP;
        
        -- Output the total charge for all sessions
        DBMS_OUTPUT.PUT_LINE('Total charge for all sessions: ' || TO_CHAR(v_total_charge, 'FM999990.00'));
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Exception handling
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END ListCustomerParkingSessions;
/


-- Test Case 1: Valid customer ID with sessions in the date range
EXEC ListCustomerParkingSessions(1111, TO_TIMESTAMP('2023-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-10 23:59:59', 'YYYY-MM-DD HH24:MI:SS'));

-- Test Case 2: Invalid customer ID
EXEC ListCustomerParkingSessions(0000, TO_TIMESTAMP('2023-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-10 23:59:59', 'YYYY-MM-DD HH24:MI:SS'));

-- Test Case 3: Valid customer ID but no sessions in the date range
EXEC ListCustomerParkingSessions(2222, TO_TIMESTAMP('2023-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-10 23:59:59', 'YYYY-MM-DD HH24:MI:SS'));

-- Test Case 4: Valid customer ID with a session partially in the date range
EXEC ListCustomerParkingSessions(3333, TO_TIMESTAMP('2023-10-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-04 23:59:59', 'YYYY-MM-DD HH24:MI:SS'));


SELECT * FROM parking_session;



--Feature 6: Elizabeth
drop sequence start_parking_session;
CREATE OR REPLACE PROCEDURE start_parking_session (
    customer_id IN INT,
    vehicle_id IN INT,
    zone_id IN INT,
    session_start_time IN TIMESTAMP,
    hours_to_park IN INT
) AS
    v_zone_capacity INT;
    v_open_spots INT;
    v_max_parking_length INT;
    v_effective_start TIMESTAMP;
    v_effective_end TIMESTAMP;
BEGIN
    -- Check if customer ID is valid
    SELECT COUNT(*) INTO v_zone_capacity FROM customer WHERE cid = customer_id;
    IF v_zone_capacity = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid customer ID');
        RETURN;
    END IF;

    -- Check if vehicle ID is valid
    SELECT COUNT(*) INTO v_zone_capacity FROM vehicle WHERE vid = vehicle_id;
    IF v_zone_capacity = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid vehicle ID');
        RETURN;
    END IF;

    -- Check if zone ID is valid
    SELECT COUNT(*) INTO v_zone_capacity FROM parking_zone WHERE zid = zone_id;
    IF v_zone_capacity = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid zone ID');
        RETURN;
    END IF;

    -- Retrieve zone information
    SELECT capacity, open_spots, max, effective_start, effective_end
    INTO v_zone_capacity, v_open_spots, v_max_parking_length, v_effective_start, v_effective_end
    FROM parking_zone
    WHERE zid = zone_id;

    -- Check conditions a) and b)
    IF v_open_spots = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Parking session not possible due to no available spot');
    ELSIF (session_start_time < v_effective_start OR session_start_time > v_effective_end) AND hours_to_park > v_max_parking_length THEN
        DBMS_OUTPUT.PUT_LINE('Error: Parking length exceeds maximal length');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Parking session started successfully');
        -- Additional logic for starting the parking session can be added here
    END IF;
END;
/

Select * from parking_session;

--Test Case 1:  Start a parking session for customer ID 1111, vehicle ID 9999, zone ID 1000, starting at '2023-10-04 16:00:00' for 3 hours. (will work)
EXEC start_parking_session(1111, 9999, 1000, TIMESTAMP '2023-10-04 16:00:00', 1);

--Test Case 2:  Start a parking session for customer ID 2812, vehicle ID 3993, zone ID 1000, starting at '2023-10-04 16:00:00' for 3 hours. (will not work since the customer ID & vehicle ID are not valid)
EXEC start_parking_session(2812, 3993, 1000, TIMESTAMP '2023-12-04 16:00:00', 3);

--Test Case 3: This will return an error message since the customer is trying to park in a parking zone that does not exist
EXEC start_parking_session(1111, 9999, 1919, TIMESTAMP '2023-10-04 16:00:00', 2);


--Feature 7: Alex
drop sequence extend_session;
create or replace procedure extend_session(v_pid in int, v_cid in int, new_endtime in timestamp) as 
 value_exists number;
 v_max_session_time timestamp;
 session_duration INTERVAL DAY TO SECOND;
BEGIN
 select count(*) into value_exists
 from parking_session 
 where pid = v_pid and cid = v_cid;
 IF value_exists = 0 then
  DBMS_OUTPUT.PUT_LINE('Invalid session ID');
 ELSE 
  select max_session_time into v_max_session_time 
  from parking_session 
  where pid = v_pid and cid = v_cid;
  IF new_endtime <= v_max_session_time then
   update parking_session
   set end_time = new_endtime
   where pid = v_pid and cid = v_cid;
   DBMS_OUTPUT.PUT_LINE('Session extended successfully');
   DBMS_OUTPUT.PUT_LINE('New end time: ' || new_endtime);
  ELSE 
   DBMS_OUTPUT.PUT_LINE('Cannot extend the session because of maximal  length reached');
  END IF;
END IF;
END;
/
select * from parking_session;

--test case 1: 
-- this will successfully extend a session as the parking and customer IDs have a parking session and the new end time is before the maximum parking session time of 8:30 PM.
exec extend_session(23979, 1111, timestamp '2023-10-04 19:30:00'); --valid input
Select * from parking_session;
--test case 2: 
--this will not extend a session due to the session ID not existing within the pre-existing parking sessions. 
exec extend_session(12345, 12345, timestamp '2023-10-04 19:30:00'); -- invalid session id
Select * from parking_session;
--test case 3: 
--this will not extend a session because the new end time in this command is past the maximal session length that was determined in the original insert statements.
exec extend_session (57382, 2222, timestamp '2023-10-04 20:50:00'); -- invalid end time
Select * from parking_session;




--Feature 9: Zipporah
DROP SEQUENCE message_seq;
CREATE SEQUENCE message_seq
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;

CREATE OR REPLACE PROCEDURE CreateSessionExpiryReminders (
    v_current_time IN TIMESTAMP
) AS
    v_minutes_left INT;
    v_message_body VARCHAR2(200);
    v_new_mid message.MID%TYPE;
BEGIN
    FOR session_rec IN (
        SELECT PID, CID, end_time
        FROM parking_session
        WHERE end_time BETWEEN v_current_time - INTERVAL '15' MINUTE AND v_current_time
    ) LOOP
        -- Calculate the minutes left until the session expires
        v_minutes_left := EXTRACT(MINUTE FROM (session_rec.end_time - v_current_time)) +
                          EXTRACT(HOUR FROM (session_rec.end_time - v_current_time)) * 60;

        -- Create the message body
        v_message_body := 'Session ' || session_rec.PID || ' will expire in ' || v_minutes_left || ' minutes, please extend it if necessary.';

        -- Insert the reminder message into the message table
        -- Assuming a sequence 'message_seq' exists for generating message IDs
        SELECT message_seq.NEXTVAL INTO v_new_mid FROM DUAL;

        INSERT INTO message (MID, CID, message_time, body)
        VALUES (v_new_mid, session_rec.CID, v_current_time, v_message_body);

        -- Print the confirmation message
        DBMS_OUTPUT.PUT_LINE('Message generated for session ' || session_rec.PID);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        -- Error handling with detailed exception information
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        -- Optionally include the error backtrace for more detail
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END CreateSessionExpiryReminders;
/

-- Case 1:  Sessions expiring within the next 15 minutes
SET SERVEROUTPUT ON;
EXEC CreateSessionExpiryReminders(TO_TIMESTAMP('2023-10-04 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Case 2: No sessions expiring within the next 15 minutes
SET SERVEROUTPUT ON;
EXEC CreateSessionExpiryReminders(TO_TIMESTAMP('2023-10-05 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Case 3: Sessions expiring at the edge of the 15-minute window
SET SERVEROUTPUT ON;
EXEC CreateSessionExpiryReminders(TO_TIMESTAMP('2023-10-04 18:30:00', 'YYYY-MM-DD HH24:MI:SS'));

SELECT * FROM parking_session;

