CREATE TABLE adjustment_effects (
	adjustment_effect_id	integer primary key,
	adjustment_effect_name	varchar(50) not null
);

ALTER TABLE adjustments ADD adjustment_effect_id	integer references adjustment_effects;
CREATE INDEX adjustments_adjustment_effect_id ON adjustments(adjustment_effect_id);

INSERT INTO adjustment_effects (adjustment_effect_id, adjustment_effect_name) VALUES (0, 'General');
INSERT INTO adjustment_effects (adjustment_effect_id, adjustment_effect_name) VALUES (1, 'Housing');
INSERT INTO adjustment_effects (adjustment_effect_id, adjustment_effect_name) VALUES (2, 'Insurance');

UPDATE adjustments SET adjustment_effect_id = 1 WHERE adjustment_id = 69;
UPDATE adjustments SET adjustment_effect_id = 2 WHERE adjustment_id IN (40,63,45,64);

CREATE OR REPLACE FUNCTION getAdjustment(int, int, int) RETURNS float AS $$
DECLARE
	adjustment float;
BEGIN

	IF ($3 = 1) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (adjustment_type = $2);
	ELSIF ($3 = 2) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (adjustment_type = $2) AND (In_payroll = true) AND (Visible = true);
	ELSIF ($3 = 3) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (adjustment_type = $2) AND (In_Tax = true);
	ELSIF ($3 = 4) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (adjustment_type = $2) AND (In_payroll = true);
	ELSIF ($3 = 5) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (adjustment_type = $2) AND (Visible = true);
	ELSIF ($3 = 11) THEN
		SELECT SUM(exchange_rate * (amount + additional)) INTO adjustment
		FROM employee_tax_types
		WHERE (Employee_Month_ID = $1);
	ELSIF ($3 = 12) THEN
		SELECT SUM(exchange_rate * (amount + additional)) INTO adjustment
		FROM employee_tax_types
		WHERE (Employee_Month_ID = $1) AND (In_Tax = true);
	ELSIF ($3 = 14) THEN
		SELECT SUM(exchange_rate * (amount + additional)) INTO adjustment
		FROM employee_tax_types
		WHERE (Employee_Month_ID = $1) AND (Tax_Type_ID = $2);
	ELSIF ($3 = 21) THEN
		SELECT SUM(exchange_rate * amount * adjustment_factor) INTO adjustment
		FROM employee_adjustments
		WHERE (employee_month_id = $1) AND (in_tax = true);
	ELSIF ($3 = 22) THEN
		SELECT SUM(exchange_rate * amount * adjustment_factor) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (In_payroll = true) AND (Visible = true);
	ELSIF ($3 = 23) THEN
		SELECT SUM(exchange_rate * amount * adjustment_factor) INTO adjustment
		FROM employee_adjustments
		WHERE (employee_month_id = $1) AND (in_tax = true) AND (adjustment_factor = 1);
	ELSIF ($3 = 24) THEN
		SELECT SUM(exchange_rate * tax_reduction_amount) INTO adjustment
		FROM employee_adjustments
		WHERE (employee_month_id = $1) AND (in_tax = true) AND (adjustment_factor = -1);
	ELSIF ($3 = 25) THEN
		SELECT SUM(exchange_rate * tax_relief_amount) INTO adjustment
		FROM employee_adjustments
		WHERE (employee_month_id = $1) AND (in_tax = true) AND (adjustment_factor = -1);
	ELSIF ($3 = 26) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_adjustments
		WHERE (employee_month_id = $1) AND (pension_id is not null) AND (adjustment_type = 2);
	ELSIF ($3 = 27) THEN
		SELECT SUM(employee_adjustments.exchange_rate * employee_adjustments.amount) INTO adjustment
		FROM employee_adjustments INNER JOIN adjustments ON employee_adjustments.adjustment_id = adjustments.adjustment_id
		WHERE (employee_adjustments.employee_month_id = $1) AND (adjustments.adjustment_effect_id = $2);
	ELSIF ($3 = 28) THEN
		SELECT SUM(employee_adjustments.exchange_rate * employee_adjustments.tax_relief_amount) INTO adjustment
		FROM employee_adjustments INNER JOIN adjustments ON employee_adjustments.adjustment_id = adjustments.adjustment_id
		WHERE (employee_adjustments.employee_month_id = $1) AND (adjustments.adjustment_effect_id = $2);
	ELSIF ($3 = 31) THEN
		SELECT SUM(overtime * overtime_rate) INTO adjustment
		FROM employee_overtime
		WHERE (Employee_Month_ID = $1) AND (approve_status = 'Approved');
	ELSIF ($3 = 32) THEN
		SELECT SUM(exchange_rate * tax_amount) INTO adjustment
		FROM employee_per_diem
		WHERE (Employee_Month_ID = $1) AND (approve_status = 'Approved');
	ELSIF ($3 = 33) THEN
		SELECT SUM(exchange_rate * (full_amount -  cash_paid)) INTO adjustment
		FROM Employee_Per_Diem
		WHERE (Employee_Month_ID = $1) AND (approve_status = 'Approved');
	ELSIF ($3 = 34) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_advances
		WHERE (Employee_Month_ID = $1) AND (in_payroll = true);
	ELSIF ($3 = 35) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM advance_deductions
		WHERE (Employee_Month_ID = $1) AND (In_payroll = true);
	ELSIF ($3 = 36) THEN
		SELECT SUM(exchange_rate * paid_amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1) AND (In_payroll = true) AND (Visible = true);
	ELSIF ($3 = 37) THEN
		SELECT SUM(exchange_rate * tax_relief_amount) INTO adjustment
		FROM employee_adjustments
		WHERE (Employee_Month_ID = $1);

		IF(adjustment IS NULL)THEN
			adjustment := 0;
		END IF;
	ELSIF ($3 = 41) THEN
		SELECT SUM(exchange_rate * amount) INTO adjustment
		FROM employee_banking
		WHERE (Employee_Month_ID = $1);
	ELSE
		adjustment := 0;
	END IF;

	IF(adjustment is null) THEN
		adjustment := 0;
	END IF;

	RETURN adjustment;
END;
$$ LANGUAGE plpgsql;


