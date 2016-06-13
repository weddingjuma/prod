UPDATE orgs SET org_name = 'Dew CIS Solutions Ltd', cert_number = 'C.102554', pin = 'P051165288J', vat_number = '0142653A', 
invoice_footer = 'Make all payments to : Dew CIS Solutions ltd
Thank you for your Business
We Turn your information into profitability';

UPDATE transaction_types SET document_number = '10001';

INSERT INTO address (address_id, address_name, sys_country_id, table_name, table_id, post_office_box, postal_code, premises, street, town, phone_number, extension, mobile, fax, email, website, is_default, first_password, details) VALUES (1, NULL, 'KE', 'orgs', 0, '45689', '00100', '16th Floor, view park towers', 'Utalii Lane', 'Nairobi', '+254 (20) 2227100/2243097', NULL, '+254 725 819505 or +254 738 819505', NULL, 'accounts@dewcis.com', 'www.dewcis.com', true, NULL, NULL);

UPDATE orgs SET employee_limit = 1000, transaction_limit = 1000000;



INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '5628', 2, 0, 0, 0, 0, 'Patibandla', 'Ramya', 'sree', '1990-10-15', 'F', 'IN', 'S', '2012-02-09', NULL, NULL, true, 2, 'Full Time', 'Passport', 5000, '1234567890', NULL, true, 'English', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '5513', 3, 0, 0, 0, 0, 'Pusapati', 'Varma', 'Narasimha', '1973-10-12', 'M', 'IN', 'M', '2011-08-29', NULL, NULL, true, 2, 'Full Time', 'Passport', 35000, '1234567890', '4pic.png', true, 'English', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '2512', 4, 0, 0, 0, 0, 'Kamanda', 'Edwin', 'Geke', '1982-05-06', 'M', 'KE', 'S', '2013-02-08', NULL, '2013-08-10', false, 12, NULL, 'erweewr', 20000, '22365336142', NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '2592', 4, 0, 0, 0, 0, 'Kamau', 'Joseph', 'Wanjoki', '1977-10-16', 'M', 'KE', 'M', '2012-10-16', NULL, '2012-11-01', false, 0, NULL, '8098098098', 30000, '980809809', NULL, true, 'English', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '8783', 2, 0, 0, 0, 0, 'blackshamrat', 'Sazzadur ', 'Rahman', '1993-10-08', 'M', 'BD', 'S', '2013-10-08', NULL, NULL, false, 0, NULL, '269250', 116500, '101-105-12270', NULL, true, 'English , Bangla', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO employees (org_id, employee_id, department_role_id, pay_scale_id, pay_group_id, location_id, bank_branch_id, surname, first_name, middle_name, date_of_birth, gender, nationality, marital_status, appointment_date, current_appointment, exit_date, contract, contract_period, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, desg_code, inc_mth, previous_sal_point, current_sal_point, halt_point, interests, objective, details) 
VALUES (0, '7551', 2, 0, 0, 0, 0, 'Ondero', 'Stanley', 'Makori', '2012-11-03', 'M', 'KE', 'M', '2013-05-01', NULL, NULL, false, 0, 'Parmanent and pensionable', '25145552', 100000, '0510191137356', NULL, false, 'English', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
UPDATE employees SET currency_id = 1;

INSERT INTO applicants (org_id, surname, first_name, middle_name, applicant_email, date_of_birth, gender, nationality, marital_status, picture_file, identity_card, language, interests, objective, details) 
VALUES (0, 'Joseph', 'Kamau', 'Karanja', 'joseph.kamau@obmails.com', '1974-07-05', 'M', 'KE', 'M', NULL, '79798797998', 'English', 'Programming, study, novels', 'Career development', NULL);
INSERT INTO applicants (org_id, surname, first_name, middle_name, applicant_email, date_of_birth, gender, nationality, marital_status, picture_file, identity_card, language, interests, objective, details) 
VALUES (0, 'Gichangi', 'Dennis', 'Wachira', 'dennisgichangi@gmail.com', '1979-03-29', 'M', 'KE', 'M', NULL, '7878787', 'English', NULL, NULL, NULL);
UPDATE entitys SET first_password = 'baraza';



