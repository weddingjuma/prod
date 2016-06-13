
CREATE FUNCTION get_phase_entitys(integer) RETURNS varchar(320) AS $$
DECLARE
    myrec			RECORD;
	myentitys		varchar(320);
BEGIN
	myentitys := null;
	FOR myrec IN SELECT entitys.entity_name
		FROM entitys INNER JOIN entity_subscriptions ON entitys.entity_id = entity_subscriptions.entity_id
		WHERE (entity_subscriptions.entity_type_id = $1) LOOP

		IF (myentitys is null) THEN
			IF (myrec.entity_name is not null) THEN
				myentitys := myrec.entity_name;
			END IF;
		ELSE
			IF (myrec.entity_name is not null) THEN
				myentitys := myemail || ', ' || myrec.entity_name;
			END IF;
		END IF;

	END LOOP;

	RETURN myentitys;
END;
$$ LANGUAGE plpgsql;


ALTER TABLE orgs ADD default_country_id varchar(2) default 'KE';

CREATE OR REPLACE FUNCTION ins_loans() RETURNS trigger AS $$
DECLARE
	v_default_interest	real;
	v_reducing_balance	boolean;
BEGIN

	SELECT default_interest, reducing_balance INTO v_default_interest, v_reducing_balance
	FROM loan_types 
	WHERE (loan_type_id = NEW.loan_type_id);
	
	IF(NEW.interest is null)THEN
		NEW.interest := v_default_interest;
	END IF;
	IF (NEW.reducing_balance is null)THEN
		NEW.reducing_balance := v_reducing_balance;
	END IF;
	IF(NEW.monthly_repayment is null) THEN
		NEW.monthly_repayment := 0;
	END IF;
	IF (NEW.repayment_period is null)THEN
		NEW.repayment_period := 0;
	END IF;
	

	IF(NEW.principle is null)THEN
		RAISE EXCEPTION 'You have to enter a principle amount';
	ELSIF((NEW.monthly_repayment = 0) AND (NEW.repayment_period = 0))THEN
		RAISE EXCEPTION 'You have need to enter either monthly repayment amount or repayment period';
	ELSIF((NEW.monthly_repayment = 0) AND (NEW.repayment_period < 1))THEN
		RAISE EXCEPTION 'The repayment period should be greater than 0';
	ELSIF((NEW.repayment_period = 0) AND (NEW.monthly_repayment < 1))THEN
		RAISE EXCEPTION 'The monthly repayment should be greater than 0';
	ELSIF((NEW.monthly_repayment = 0) AND (NEW.repayment_period > 0))THEN
		NEW.monthly_repayment := NEW.principle / NEW.repayment_period;
	ELSIF((NEW.repayment_period = 0) AND (NEW.monthly_repayment > 0))THEN
		NEW.repayment_period := NEW.principle / NEW.monthly_repayment;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_loans BEFORE INSERT OR UPDATE ON loans
    FOR EACH ROW EXECUTE PROCEDURE ins_loans();


CREATE OR REPLACE FUNCTION loan_aplication(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	msg 				varchar(120);
BEGIN
	msg := 'Loan applied';
	
	UPDATE loans SET approve_status = 'Completed'
	WHERE (loan_id = CAST($1 as int)) AND (approve_status = 'Draft');

	return msg;
END;
$$ LANGUAGE plpgsql;
    

CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON loans
    FOR EACH ROW EXECUTE PROCEDURE upd_action();
    

    
CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON employee_advances
    FOR EACH ROW EXECUTE PROCEDURE upd_action();
    
    
CREATE OR REPLACE FUNCTION advance_aplication(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	msg 				varchar(120);
BEGIN
	msg := 'Advance applied';
	
	UPDATE employee_advances SET approve_status = 'Completed'
	WHERE (employee_advance_id = CAST($1 as int)) AND (approve_status = 'Draft');

	return msg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ins_employee_advances() RETURNS trigger AS $$
DECLARE
	v_period_id			integer;
BEGIN

	IF(NEW.pay_upto is null)THEN
		NEW.pay_upto := current_date;
	END IF;
	IF(NEW.payment_amount is null)THEN
		NEW.payment_amount := NEW.amount;
		NEW.pay_period := 1;
	END IF;

	IF((NEW.approve_status = 'Approved') AND (OLD.approve_status = 'Completed'))THEN
		SELECT max(period_id) INTO v_period_id
		FROM periods
		WHERE (closed = false);
		
		SELECT max(employee_month_id) INTO NEW.employee_month_id
		FROM employee_month
		WHERE (period_id = v_period_id) AND (entity_id = NEW.entity_id);
		
		IF(v_period_id is null)THEN
			RAISE EXCEPTION 'You need to have the current period approved';
		ELSIF(NEW.employee_month_id is null)THEN
			RAISE EXCEPTION 'You need to have the staff in the current active month';
		END IF;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_employee_advances BEFORE INSERT OR UPDATE ON employee_advances
    FOR EACH ROW EXECUTE PROCEDURE ins_employee_advances();
    
