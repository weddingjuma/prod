CREATE TABLE adjustment_effects (
	adjustment_effect_id	integer primary key,
	adjustment_effect_name	varchar(50) not null
);

CREATE TABLE adjustments (
	adjustment_id			serial primary key,
	currency_id				integer references currency,
	adjustment_effect_id	integer references adjustment_effects,
	org_id					integer references orgs,
	adjustment_name			varchar(50) not null,
	adjustment_type			integer not null,
	adjustment_order		integer default 0 not null,
	earning_code			integer,
	formural				varchar(430),
	default_amount			real default 0 not null,
	monthly_update			boolean default true not null,
	in_payroll				boolean default true not null,
	in_tax					boolean default true not null,
	visible					boolean default true not null,
	running_balance			boolean default false not null,
	reduce_balance			boolean default false not null,

	tax_reduction_ps		float default 0 not null,
	tax_relief_ps			float default 0 not null,
	tax_max_allowed			float default 0 not null,

	account_number			varchar(32),
	details					text,
	
	UNIQUE(adjustment_name, org_id)
);
CREATE INDEX adjustments_currency_id ON adjustments(currency_id);
CREATE INDEX adjustments_adjustment_effect_id ON adjustments(adjustment_effect_id);
CREATE INDEX adjustments_org_id ON adjustments(org_id);

CREATE TABLE claim_types (
	claim_type_id			serial primary key,
	adjustment_id			integer references adjustments,
	org_id					integer references orgs,
	claim_type_name			varchar(50),
	details					text
);
CREATE INDEX claim_types_adjustment_id ON claim_types(adjustment_id);
CREATE INDEX claim_types_org_id ON claim_types(org_id);

CREATE TABLE default_adjustments (
	default_adjustment_id	serial primary key,
	entity_id				integer references entitys,
	adjustment_id			integer references adjustments,
	org_id					integer references orgs,
	
	amount					float default 0 not null,
	balance					float default 0 not null,
	final_date				date,
	active					boolean default true,

	Narrative				varchar(240)
);
CREATE INDEX default_adjustments_entity_id ON default_adjustments (entity_id);
CREATE INDEX default_adjustments_adjustment_id ON default_adjustments (adjustment_id);
CREATE INDEX default_adjustments_org_id ON default_adjustments(org_id);

CREATE TABLE default_banking (
	default_banking_id		serial primary key,
	entity_id				integer references entitys,
	bank_branch_id			integer references bank_branch,
	currency_id				integer references currency,
	org_id					integer references orgs,
	
	amount					float default 0 not null,
	ps_amount				float default 0 not null,
	final_date				date,
	active					boolean default true,
	
	bank_account			varchar(64),

	Narrative				varchar(240)
);
CREATE INDEX default_banking_entity_id ON default_banking (entity_id);
CREATE INDEX default_banking_bank_branch_id ON default_banking (bank_branch_id);
CREATE INDEX default_banking_currency_id ON default_banking (currency_id);
CREATE INDEX default_banking_org_id ON default_banking(org_id);

CREATE TABLE pensions (
	pension_id 				serial primary key,
	entity_id				integer references entitys,
	adjustment_id			integer references adjustments,
	contribution_id			integer references adjustments,
	org_id					integer references orgs,
	
	pension_company			varchar(50) not null,
	pension_number			varchar(50),
	active					boolean default true,
	
	amount					float default 0 not null,
	use_formura				boolean default false not null,
	
	employer_ps				float default 0 not null,
	employer_amount			float default 0 not null,
	employer_formural		boolean default false not null,
	
	details					text
);
CREATE INDEX pension_entity_id ON pensions (entity_id);
CREATE INDEX pension_adjustment_id ON pensions (adjustment_id);
CREATE INDEX pension_contribution_id ON pensions (contribution_id);
CREATE INDEX pension_org_id ON pensions (org_id);

CREATE TABLE employee_month (
	employee_month_id		serial primary key,
	entity_id				integer references entitys not null,
	period_id				integer references periods not null,
	bank_branch_id			integer references bank_branch not null,
	pay_group_id			integer references pay_groups not null,
	department_role_id		integer references department_roles not null,
	currency_id				integer references currency,
	org_id					integer references orgs,
	
	exchange_rate			real default 1 not null,
	bank_account			varchar(32),
	basic_pay				float default 0 not null,
	details					text,
	unique (entity_id, period_id)
);
CREATE INDEX employee_month_entity_id ON employee_month (entity_id);
CREATE INDEX employee_month_period_id ON employee_month (period_id);
CREATE INDEX employee_month_bank_branch_id ON employee_month (bank_branch_id);
CREATE INDEX employee_month_bank_pay_group_id ON employee_month (pay_group_id);
CREATE INDEX employee_month_currency_id ON employee_month (currency_id);
CREATE INDEX employee_month_org_id ON employee_month(org_id);

CREATE TABLE employee_tax_types (
	employee_tax_type_id	serial primary key,
	employee_month_id		integer references employee_month not null,
	tax_type_id				integer references tax_types not null,
	org_id					integer references orgs,
	
	tax_identification		varchar(50),
	in_tax					boolean not null default false,
	amount					float default 0 not null,
	additional				float default 0 not null,
	employer				float default 0 not null,
	exchange_rate			real default 1 not null,
	
	narrative				varchar(240)
);
CREATE INDEX employee_tax_types_employee_month_id ON employee_tax_types (employee_month_id);
CREATE INDEX employee_tax_types_tax_type_id ON employee_tax_types (tax_type_id);
CREATE INDEX employee_tax_types_org_id ON employee_tax_types(org_id);

CREATE TABLE employee_advances (
	employee_advance_id		serial primary key,
	employee_month_id		integer references employee_month,
	currency_id				integer references currency,
	entity_id				integer not null references entitys,
	org_id					integer references orgs,
	pay_date				date default current_date not null,
	pay_upto				date not null,
	pay_period				integer default 3 not null,
	amount					float not null,
	payment_amount			float not null,
	exchange_rate			real default 1 not null,
	in_payroll				boolean not null default false,
	completed				boolean not null default false,

	application_date		timestamp default now(),
	approve_status			varchar(16) default 'Draft' not null,
	workflow_table_id		integer,
	action_date				timestamp,

	narrative				varchar(240),
	details					text
);
CREATE INDEX employee_advances_employee_month_id ON employee_advances (employee_month_id);
CREATE INDEX employee_advances_currency_id ON employee_advances (currency_id);
CREATE INDEX employee_advances_entity_id ON employee_advances (entity_id);
CREATE INDEX employee_advances_org_id ON employee_advances(org_id);

CREATE TABLE advance_deductions (
	advance_deduction_id	serial primary key,
	employee_month_id		integer references employee_month not null,
	org_id					integer references orgs,
	pay_date				date default current_date not null,
	amount					float not null,
	exchange_rate			real default 1 not null,
	in_payroll				boolean not null default true,
	narrative				varchar(240)
);
CREATE INDEX advance_deductions_employee_month_id ON advance_deductions (employee_month_id);
CREATE INDEX advance_deductions_org_id ON advance_deductions(org_id);

CREATE TABLE employee_adjustments (
	employee_adjustment_id	serial primary key,
	employee_month_id		integer references employee_month not null,
	adjustment_id			integer references adjustments not null,
	pension_id				integer references pensions,
	org_id					integer references orgs,
	adjustment_type			integer,
	adjustment_factor		integer default 1 not null,
	pay_date				date default current_date not null,
	amount					float not null,
	balance					float,
	paid_amount				float default 0 not null,
	exchange_rate			real default 1 not null,

	tax_reduction_amount	float default 0 not null,
	tax_relief_amount		float default 0 not null,

	in_payroll				boolean not null default true,
	in_tax					boolean not null default true,
	visible					boolean not null default true,
	narrative				varchar(240)
);
CREATE INDEX employee_adjustments_employee_month_id ON employee_adjustments (employee_month_id);
CREATE INDEX employee_adjustments_adjustment_id ON employee_adjustments (adjustment_id);
CREATE INDEX employee_adjustments_pension_id ON employee_adjustments (pension_id);
CREATE INDEX employee_adjustments_org_id ON employee_adjustments(org_id);

CREATE TABLE claims (
	claim_id				serial primary key,
	claim_type_id			integer references claim_types,
	entity_id				integer references entitys,
	employee_adjustment_id	integer references employee_adjustments,
	org_id					integer references orgs,
	
	claim_date				date not null,
	in_payroll				boolean not null default false,
	narrative				varchar(250),
	
	process_claim			boolean not null default false,
	process_date			date,
	
	application_date		timestamp default now(),
	approve_status			varchar(16) default 'Draft' not null,
	workflow_table_id		integer,
	action_date				timestamp,
	
	details					text
);
CREATE INDEX claims_claim_type_id ON claims(claim_type_id);
CREATE INDEX claims_entity_id ON claims(entity_id);
CREATE INDEX claims_employee_adjustment_id ON claims(employee_adjustment_id);
CREATE INDEX claims_org_id ON claims(org_id);

CREATE TABLE claim_details (
	claim_detail_id			serial primary key,
	claim_id				integer references claims,
	currency_id				integer references currency,
	org_id					integer references orgs,
	
	nature_of_expence		varchar(50),
	receipt_number			varchar(50),
	amount					real not null,
	exchange_rate			real default 1 not null,
	expense_code			varchar(50),

	details					text
);
CREATE INDEX claim_details_claim_id ON claim_details(claim_id);
CREATE INDEX claim_details_currency_id ON claim_details(currency_id);
CREATE INDEX claim_details_org_id ON claim_details(org_id);

CREATE TABLE employee_overtime (
	employee_overtime_id	serial primary key,
	employee_month_id		integer references employee_month not null,
	org_id					integer references orgs,
	overtime_date			date not null,
	overtime				float not null,
	overtime_rate			float not null,
	application_date		timestamp default now(),
	approve_status			varchar(16) default 'draft' not null,
	workflow_table_id		integer,
	action_date				timestamp,
	narrative				varchar(240),
	details					text
);
CREATE INDEX employee_overtime_employee_month_id ON employee_overtime (employee_month_id);
CREATE INDEX employee_overtime_org_id ON employee_overtime(org_id);

CREATE TABLE employee_per_diem (
	employee_per_diem_id	serial primary key,
	employee_month_id		integer references employee_month not null,
	currency_id				integer references currency,
	org_id					integer references orgs,
	travel_date				date not null,
	return_date				date not null,
	days_travelled			integer not null,
	per_diem				float default 0 not null,
	cash_paid				float default 0 not null,
	tax_amount				float default 0 not null,
	full_amount				float default 0 not null,
	exchange_rate			real default 1 not null,
	travel_to				varchar(240),
	post_account			varchar(32),
	application_date		timestamp default now(),
	approve_status			varchar(16) default 'draft' not null,
	workflow_table_id		integer,
	action_date				timestamp,
	completed				boolean default false not null,
	details					text
);
CREATE INDEX employee_per_diem_employee_month_id ON employee_per_diem (employee_month_id);
CREATE INDEX employee_per_diem_currency_id ON employee_per_diem (currency_id);
CREATE INDEX employee_per_diem_org_id ON employee_per_diem(org_id);

CREATE TABLE employee_banking (
	employee_banking_id		serial primary key,
	employee_month_id		integer references employee_month not null,
	bank_branch_id			integer references bank_branch,
	currency_id				integer references currency,
	org_id					integer references orgs,
	
	amount					float default 0 not null,
	exchange_rate			real default 1 not null,
	active					boolean default true,
	
	bank_account			varchar(64),

	Narrative				varchar(240)
);
CREATE INDEX employee_banking_employee_month_id ON employee_banking (employee_month_id);
CREATE INDEX employee_banking_bank_branch_id ON employee_banking (bank_branch_id);
CREATE INDEX employee_banking_currency_id ON employee_banking (currency_id);
CREATE INDEX employee_banking_org_id ON employee_banking(org_id);

CREATE TABLE payroll_ledger (
	payroll_ledger_id		serial primary key,
	currency_id				integer references currency,
	org_id					integer references orgs,
	period_id				integer, 
	posting_date			date, 
	description				varchar(240), 
	payroll_account			varchar(16), 
	dr_amt					numeric(12, 2),
	cr_amt					numeric(12, 2),
	exchange_rate			real default 1 not null,
	posted					boolean default false
);
CREATE INDEX payroll_ledger_currency_id ON payroll_ledger(currency_id);
CREATE INDEX payroll_ledger_org_id ON payroll_ledger(org_id);

CREATE VIEW vw_adjustments AS
	SELECT currency.currency_id, currency.currency_name, currency.currency_symbol,
		adjustments.org_id, adjustments.adjustment_id, adjustments.adjustment_name, adjustments.adjustment_type, 
		adjustments.adjustment_order, adjustments.earning_code, adjustments.formural, adjustments.monthly_update, 
		adjustments.in_payroll, adjustments.in_tax, adjustments.visible, adjustments.running_balance, 
		adjustments.reduce_balance, adjustments.tax_reduction_ps, adjustments.tax_relief_ps, 
		adjustments.tax_max_allowed, adjustments.account_number, adjustments.details
	FROM adjustments INNER JOIN currency ON adjustments.currency_id = currency.currency_id;
		
CREATE VIEW vw_claim_types AS
	SELECT adjustments.adjustment_id, adjustments.adjustment_name, 
		claim_types.org_id, claim_types.claim_type_id, claim_types.claim_type_name, claim_types.details
	FROM claim_types INNER JOIN adjustments ON claim_types.adjustment_id = adjustments.adjustment_id;
	
CREATE VIEW vw_claims AS
	SELECT claim_types.claim_type_id, claim_types.claim_type_name, 
		entitys.entity_id, entitys.entity_name, 
		claims.org_id, claims.claim_id, claims.claim_date, claims.narrative, claims.in_payroll,
		claims.process_claim, claims.process_date,
		claims.application_date, claims.approve_status, claims.workflow_table_id, claims.action_date, 
		claims.details
	FROM claims INNER JOIN claim_types ON claims.claim_type_id = claim_types.claim_type_id
		INNER JOIN entitys ON claims.entity_id = entitys.entity_id;
		
CREATE VIEW vw_claim_details AS
	SELECT vw_claims.claim_type_id, vw_claims.claim_type_name, vw_claims.entity_id, vw_claims.entity_name, 
		vw_claims.claim_id, vw_claims.claim_date, vw_claims.narrative, vw_claims.application_date, 
		vw_claims.approve_status, vw_claims.workflow_table_id, vw_claims.action_date,

		currency.currency_id, currency.currency_name, currency.currency_symbol,
		claim_details.org_id, claim_details.claim_detail_id, claim_details.nature_of_expence, 
		claim_details.receipt_number, claim_details.amount, claim_details.exchange_rate, claim_details.expense_code, 
		claim_details.details
	FROM claim_details INNER JOIN vw_claims ON claim_details.claim_id = vw_claims.claim_id
		INNER JOIN currency ON claim_details.currency_id = currency.currency_id;

CREATE VIEW vw_default_adjustments AS
	SELECT vw_adjustments.adjustment_id, vw_adjustments.adjustment_name, vw_adjustments.adjustment_type, 
		vw_adjustments.currency_id, vw_adjustments.currency_name, vw_adjustments.currency_symbol,
		entitys.entity_id, entitys.entity_name,
		default_adjustments.org_id, default_adjustments.default_adjustment_id, default_adjustments.amount, default_adjustments.active,
		default_adjustments.final_date, default_adjustments.narrative
	FROM default_adjustments INNER JOIN vw_adjustments ON default_adjustments.adjustment_id = vw_adjustments.adjustment_id
		INNER JOIN entitys ON default_adjustments.entity_id = entitys.entity_id;

CREATE VIEW vw_default_banking AS
	SELECT entitys.entity_id, entitys.entity_name, 
		vw_bank_branch.bank_id, vw_bank_branch.bank_name, vw_bank_branch.bank_branch_id, 
		vw_bank_branch.bank_branch_name, vw_bank_branch.bank_branch_code,
		currency.currency_id, currency.currency_name, currency.currency_symbol,
		default_banking.org_id, default_banking.default_banking_id, default_banking.amount, 
		default_banking.ps_amount, default_banking.final_date, default_banking.active, 
		default_banking.bank_account, default_banking.narrative
	FROM default_banking INNER JOIN entitys ON default_banking.entity_id = entitys.entity_id
		INNER JOIN vw_bank_branch ON default_banking.bank_branch_id = vw_bank_branch.bank_branch_id
		INNER JOIN currency ON default_banking.currency_id = currency.currency_id;

CREATE VIEW vw_pensions AS
	SELECT entitys.entity_id, entitys.entity_name,
		adjustments.adjustment_id, adjustments.adjustment_name, 
		currency.currency_id, currency.currency_name, currency.currency_symbol,
		pensions.contribution_id, contributions.adjustment_name as contribution_name, 
		pensions.org_id, pensions.pension_id, pensions.pension_company, pensions.pension_number, 
		pensions.amount, pensions.use_formura, pensions.employer_ps, pensions.employer_amount, 
		pensions.employer_formural, pensions.active, pensions.details
	FROM pensions INNER JOIN entitys ON pensions.entity_id = entitys.entity_id
		INNER JOIN adjustments ON pensions.adjustment_id = adjustments.adjustment_id
		INNER JOIN adjustments as contributions ON pensions.contribution_id = contributions.adjustment_id
		INNER JOIN currency ON adjustments.currency_id = currency.currency_id;
	
	
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

CREATE OR REPLACE FUNCTION getAdjustment(int, int) RETURNS float AS $$
DECLARE
	adjustment float;
BEGIN

	IF ($2 = 1) THEN
		SELECT (Basic_Pay + getAdjustment(Employee_Month_ID, 4, 31) + getAdjustment(Employee_Month_ID, 4, 23) 
			+ getAdjustment(Employee_Month_ID, 4, 32)) INTO adjustment
		FROM Employee_Month
		WHERE (Employee_Month_ID = $1);
	ELSIF ($2 = 2) THEN
		SELECT (Basic_Pay + getAdjustment(Employee_Month_ID, 4, 31) + getAdjustment(Employee_Month_ID, 4, 23)
			- getAdjustment(Employee_Month_ID, 4, 32) 
			- getAdjustment(Employee_Month_ID, 4, 12) - getAdjustment(Employee_Month_ID, 4, 24)) INTO adjustment
		FROM Employee_Month
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

CREATE OR REPLACE FUNCTION getAdvanceBalance(int, date) RETURNS float AS $$
DECLARE
	advance FLOAT;
	paid 	FLOAT;
BEGIN
	SELECT SUM(Amount) INTO advance
	FROM vw_employee_advances
	WHERE (entity_id = $1) AND (start_date <= $2) AND (approve_status = 'Approved');
	IF (advance is null) THEN advance := 0; END IF;
	
	SELECT SUM(Amount) INTO paid
	FROM vw_advance_deductions
	WHERE (entity_id = $1) AND (start_date <= $2);
	IF (paid is null) THEN paid := 0; END IF;

	advance := advance - paid;

	RETURN advance;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW vw_employee_month AS
	SELECT vw_periods.period_id, vw_periods.start_date, vw_periods.end_date, vw_periods.overtime_rate, 
		vw_periods.activated, vw_periods.closed, vw_periods.month_id, vw_periods.period_year, vw_periods.period_month,
		vw_periods.quarter, vw_periods.semister, vw_periods.bank_header, vw_periods.bank_address,
		vw_periods.gl_payroll_account, vw_periods.gl_bank_account, vw_periods.is_posted,
		vw_bank_branch.bank_id, vw_bank_branch.bank_name, vw_bank_branch.bank_branch_id, 
		vw_bank_branch.bank_branch_name, vw_bank_branch.bank_branch_code,
		pay_groups.pay_group_id, pay_groups.pay_group_name, vw_department_roles.department_id, vw_department_roles.department_name,
		vw_department_roles.department_role_id, vw_department_roles.department_role_name, 
		entitys.entity_id, entitys.entity_name,
		employees.employee_id, employees.surname, employees.first_name, employees.middle_name, employees.date_of_birth, 
		employees.gender, employees.nationality, employees.marital_status, employees.appointment_date, employees.exit_date, 
		employees.contract, employees.contract_period, employees.employment_terms, employees.identity_card,
		(employees.Surname || ' ' || employees.First_name || ' ' || COALESCE(employees.Middle_name, '')) as employee_name,
		currency.currency_id, currency.currency_name, currency.currency_symbol, employee_month.exchange_rate,
		
		employee_month.org_id, employee_month.employee_month_id, employee_month.bank_account, employee_month.basic_pay, employee_month.details,
		getAdjustment(employee_month.employee_month_id, 4, 31) as overtime,
		getAdjustment(employee_month.employee_month_id, 1, 1) as full_allowance,
		getAdjustment(employee_month.employee_month_id, 1, 2) as payroll_allowance,
		getAdjustment(employee_month.employee_month_id, 1, 3) as tax_allowance,
		getAdjustment(employee_month.employee_month_id, 2, 1) as full_deduction,
		getAdjustment(employee_month.employee_month_id, 2, 2) as payroll_deduction,
		getAdjustment(employee_month.employee_month_id, 2, 3) as tax_deduction,
		getAdjustment(employee_month.employee_month_id, 3, 1) as full_expense,
		getAdjustment(employee_month.employee_month_id, 3, 2) as payroll_expense,
		getAdjustment(employee_month.employee_month_id, 3, 3) as tax_expense,
		getAdjustment(employee_month.employee_month_id, 4, 11) as payroll_tax,
		getAdjustment(employee_month.employee_month_id, 4, 12) as tax_tax,
		getAdjustment(employee_month.employee_month_id, 4, 22) as net_Adjustment,
		getAdjustment(employee_month.employee_month_id, 4, 33) as per_diem,
		getAdjustment(employee_month.employee_month_id, 4, 34) as advance,
		getAdjustment(employee_month.employee_month_id, 4, 35) as advance_deduction,
		(employee_month.Basic_Pay + getAdjustment(employee_month.employee_month_id, 4, 31) + getAdjustment(employee_month.employee_month_id, 4, 22) 
		+ getAdjustment(employee_month.employee_month_id, 4, 33) - getAdjustment(employee_month.employee_month_id, 4, 11)) as net_pay,
		(employee_month.Basic_Pay + getAdjustment(employee_month.employee_month_id, 4, 31) + getAdjustment(employee_month.employee_month_id, 4, 22) 
		+ getAdjustment(employee_month.employee_month_id, 4, 33) + getAdjustment(employee_month.employee_month_id, 4, 34)
		- getAdjustment(employee_month.employee_month_id, 4, 11) - getAdjustment(employee_month.employee_month_id, 4, 35)
		- getAdjustment(employee_month.employee_month_id, 4, 36)
		- getAdjustment(employee_month.employee_month_id, 4, 41)) as banked,
		(employee_month.Basic_Pay + getAdjustment(employee_month.employee_month_id, 4, 31) + getAdjustment(employee_month.employee_month_id, 1, 1) 
		+ getAdjustment(employee_month.employee_month_id, 3, 1) + getAdjustment(employee_month.employee_month_id, 4, 33)) as cost
	FROM employee_month INNER JOIN vw_bank_branch ON employee_month.bank_branch_id = vw_bank_branch.bank_branch_id
		INNER JOIN vw_periods ON employee_month.period_id = vw_periods.period_id
		INNER JOIN pay_groups ON employee_month.pay_group_id = pay_groups.pay_group_id
		INNER JOIN entitys ON employee_month.entity_id = entitys.entity_id
		INNER JOIN vw_department_roles ON employee_month.department_role_id = vw_department_roles.department_role_id
		INNER JOIN employees ON employee_month.entity_id = employees.entity_id
		INNER JOIN currency ON employee_month.currency_id = currency.currency_id;

CREATE VIEW vw_employee_month_list AS
	SELECT vw_periods.period_id, vw_periods.start_date, vw_periods.end_date, vw_periods.overtime_rate, 
		vw_periods.activated, vw_periods.closed, vw_periods.month_id, vw_periods.period_year, vw_periods.period_month,
		vw_periods.quarter, vw_periods.semister, vw_periods.bank_header, vw_periods.bank_address,
		vw_periods.gl_payroll_account, vw_periods.gl_bank_account, vw_periods.is_posted, 
		entitys.entity_id, entitys.entity_name,
		employees.employee_id, employees.surname, employees.first_name, employees.middle_name, employees.date_of_birth, 
		employees.gender, employees.nationality, employees.marital_status, employees.appointment_date, employees.exit_date, 
		employees.contract, employees.contract_period, employees.employment_terms, employees.identity_card,
		(employees.Surname || ' ' || employees.First_name || ' ' || COALESCE(employees.Middle_name, '')) as employee_name,
		departments.department_id, departments.department_name, departments.department_account, departments.function_code,
		department_roles.department_role_id, department_roles.department_role_name,
		employee_month.pay_group_id,
		employee_month.org_id, employee_month.employee_month_id, employee_month.bank_account, employee_month.basic_pay
		
	FROM employee_month INNER JOIN vw_periods ON employee_month.period_id = vw_periods.period_id
		INNER JOIN entitys ON employee_month.entity_id = entitys.entity_id
		INNER JOIN employees ON employee_month.entity_id = employees.entity_id
		INNER JOIN department_roles ON employee_month.department_role_id = department_roles.department_role_id
		INNER JOIN departments ON department_roles.department_id = departments.department_id;

CREATE VIEW vw_employee_tax_types AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.end_date, eml.gl_payroll_account,
		eml.entity_id, eml.entity_name, eml.employee_id, eml.identity_card,
		eml.surname, eml.first_name, eml.middle_name, eml.date_of_birth, 
		eml.department_id, eml.department_name, eml.department_account, eml.function_code,
		eml.department_role_id, eml.department_role_name,
		tax_types.tax_type_id, tax_types.tax_type_name, tax_types.account_id, tax_types.tax_type_number,
		tax_types.account_number, tax_types.employer_account,
		employee_tax_types.org_id, employee_tax_types.employee_tax_type_id, employee_tax_types.tax_identification, 
		employee_tax_types.amount, 
		employee_tax_types.additional, employee_tax_types.employer, employee_tax_types.narrative,
		currency.currency_id, currency.currency_name, currency.currency_symbol, employee_tax_types.exchange_rate,
		
		(employee_tax_types.exchange_rate * employee_tax_types.amount) as base_amount,
		(employee_tax_types.exchange_rate * employee_tax_types.employer) as base_employer,
		(employee_tax_types.exchange_rate * employee_tax_types.additional) as base_additional
		
	FROM employee_tax_types INNER JOIN vw_employee_month_list as eml ON employee_tax_types.employee_month_id = eml.employee_month_id
		INNER JOIN tax_types ON (employee_tax_types.tax_type_id = tax_types.tax_type_id)
		INNER JOIN currency ON tax_types.currency_id = currency.currency_id;
		
CREATE VIEW vw_employee_tax_month AS
	SELECT emp.period_id, emp.start_date, emp.end_date, emp.overtime_rate, 
		emp.activated, emp.closed, emp.month_id, emp.period_year, emp.period_month,
		emp.quarter, emp.semister, emp.bank_header, emp.bank_address,
		emp.gl_payroll_account, emp.gl_bank_account, emp.is_posted,
		emp.bank_id, emp.bank_name, emp.bank_branch_id, 
		emp.bank_branch_name, emp.bank_branch_code,
		emp.pay_group_id, emp.pay_group_name, emp.department_id, emp.department_name,
		emp.department_role_id, emp.department_role_name, 
		emp.entity_id, emp.entity_name,
		emp.employee_id, emp.surname, emp.first_name, emp.middle_name, emp.date_of_birth, 
		emp.gender, emp.nationality, emp.marital_status, emp.appointment_date, emp.exit_date, 
		emp.contract, emp.contract_period, emp.employment_terms, emp.identity_card,
		emp.employee_name,
		emp.currency_id, emp.currency_name, emp.currency_symbol, emp.exchange_rate,
		
		emp.org_id, emp.employee_month_id, emp.bank_account, emp.basic_pay, emp.details,
		emp.overtime, emp.full_allowance, emp.payroll_allowance, emp.tax_allowance,
		emp.full_deduction, emp.payroll_deduction, emp.tax_deduction, emp.full_expense,
		emp.payroll_expense, emp.tax_expense, emp.payroll_tax, emp.tax_tax,
		emp.net_adjustment, emp.per_diem, emp.advance, emp.advance_deduction,
		emp.net_pay, emp.banked, emp.cost,
		
		tax_types.tax_type_id, tax_types.tax_type_name, tax_types.account_id, 
		employee_tax_types.employee_tax_type_id, employee_tax_types.tax_identification, 
		employee_tax_types.amount, employee_tax_types.exchange_rate as tax_exchange_rate,
		employee_tax_types.additional, employee_tax_types.employer, employee_tax_types.narrative,
		
		(employee_tax_types.amount * employee_tax_types.exchange_rate) as tax_base_amount

	FROM vw_employee_month as emp INNER JOIN employee_tax_types ON emp.employee_month_id = employee_tax_types.employee_month_id
		INNER JOIN tax_types ON employee_tax_types.tax_type_id = tax_types.tax_type_id;
	
CREATE VIEW vw_employee_advances AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, eml.end_date,
		eml.month_id, eml.period_year, eml.period_month, 
		eml.gl_payroll_account, eml.gl_bank_account,
		eml.entity_id, eml.entity_name, eml.employee_id,
		employee_advances.org_id, employee_advances.employee_advance_id, employee_advances.pay_date, employee_advances.pay_period, 
		employee_advances.Pay_upto, employee_advances.amount, employee_advances.in_payroll, employee_advances.completed, 
		employee_advances.approve_status, employee_advances.Action_date, employee_advances.narrative
	FROM employee_advances INNER JOIN vw_employee_month_list as eml ON employee_advances.employee_month_id = eml.employee_month_id;

CREATE VIEW vw_advance_deductions AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, eml.end_date,
		eml.month_id, eml.period_year, eml.period_month,
		eml.gl_payroll_account, eml.gl_bank_account,
		eml.entity_id, eml.entity_name, eml.employee_id,
		advance_deductions.org_id, advance_deductions.advance_deduction_id, advance_deductions.pay_date, advance_deductions.amount, 
		advance_deductions.in_payroll, advance_deductions.narrative
	FROM advance_deductions INNER JOIN vw_employee_month_list as eml ON advance_deductions.employee_month_id = eml.employee_month_id;

CREATE VIEW vw_advance_statement AS
	(SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.entity_id, eml.entity_name, eml.employee_id,
		employee_advances.org_id, employee_advances.pay_date, employee_advances.in_payroll, employee_advances.narrative,
		employee_advances.amount, cast(0 as real) as recovery
	FROM employee_advances INNER JOIN vw_employee_month_list as eml ON employee_advances.employee_month_id = eml.employee_month_id
	WHERE (employee_advances.approve_status = 'Approved'))
	UNION
	(SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.entity_id, eml.entity_name, eml.employee_id,
		advance_deductions.org_id, advance_deductions.pay_date, advance_deductions.in_payroll, advance_deductions.narrative, 
		cast(0 as real), advance_deductions.amount
	FROM advance_deductions INNER JOIN vw_employee_month_list as eml ON advance_deductions.employee_month_id = eml.employee_month_id);

CREATE VIEW vw_employee_adjustments AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.end_date, 
		eml.entity_id, eml.entity_name, eml.employee_id, eml.identity_card,
		eml.department_id, eml.department_name, eml.department_account, eml.function_code,
		eml.department_role_id, eml.department_role_name,
		adjustments.adjustment_id, adjustments.adjustment_name, adjustments.adjustment_type, adjustments.account_number, 
		adjustments.earning_code,
		currency.currency_id, currency.currency_name, currency.currency_symbol,
		employee_adjustments.org_id, employee_adjustments.employee_adjustment_id, employee_adjustments.pay_date, employee_adjustments.amount, 
		employee_adjustments.in_payroll, employee_adjustments.in_tax, employee_adjustments.visible, employee_adjustments.exchange_rate,
		employee_adjustments.paid_amount, employee_adjustments.balance, employee_adjustments.narrative,
		employee_adjustments.tax_relief_amount,
		(employee_adjustments.exchange_rate * employee_adjustments.amount) as base_amount		
	FROM employee_adjustments INNER JOIN adjustments ON employee_adjustments.adjustment_id = adjustments.adjustment_id
		INNER JOIN vw_employee_month_list as eml ON employee_adjustments.employee_month_id = eml.employee_month_id
		INNER JOIN currency ON adjustments.currency_id = currency.currency_id;

CREATE VIEW vw_employee_overtime AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.entity_id, eml.entity_name, eml.employee_id,
		employee_overtime.org_id, employee_overtime.employee_overtime_id, employee_overtime.overtime_date, employee_overtime.overtime, 
		employee_overtime.overtime_rate, employee_overtime.narrative, employee_overtime.approve_status, 
		employee_overtime.Action_date, employee_overtime.details
	FROM employee_overtime INNER JOIN vw_employee_month_list as eml ON employee_overtime.employee_month_id = eml.employee_month_id;

CREATE VIEW vw_employee_per_diem AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.entity_id, eml.entity_name, eml.employee_id,
		employee_per_diem.org_id, employee_per_diem.employee_per_diem_id, employee_per_diem.travel_date, employee_per_diem.return_date, employee_per_diem.days_travelled, 
		employee_per_diem.per_diem, employee_per_diem.cash_paid, employee_per_diem.tax_amount, employee_per_diem.full_amount,
		employee_per_diem.travel_to,  employee_per_diem.approve_status, employee_per_diem.action_date, 
		employee_per_diem.completed, employee_per_diem.post_account, employee_per_diem.details,
		(employee_per_diem.exchange_rate * employee_per_diem.tax_amount) as base_tax_amount, 
		(employee_per_diem.exchange_rate *  employee_per_diem.full_amount) as base_full_amount
	FROM employee_per_diem INNER JOIN vw_employee_month_list as eml ON employee_per_diem.employee_month_id = eml.employee_month_id;
	
CREATE VIEW vw_employee_banking AS
	SELECT eml.employee_month_id, eml.period_id, eml.start_date, 
		eml.month_id, eml.period_year, eml.period_month,
		eml.entity_id, eml.entity_name, eml.employee_id,
		eml.pay_group_id, eml.bank_Header, eml.bank_address,
		vw_bank_branch.bank_id, vw_bank_branch.bank_name, vw_bank_branch.bank_branch_id, 
		vw_bank_branch.bank_branch_name, vw_bank_branch.bank_branch_code,
		currency.currency_id, currency.currency_name, currency.currency_symbol,
		
		employee_banking.org_id, employee_banking.employee_banking_id, employee_banking.amount, 
		employee_banking.exchange_rate, employee_banking.active, employee_banking.bank_account,
		employee_banking.narrative,
		(employee_banking.exchange_rate * employee_banking.amount) as base_amount
	FROM employee_banking INNER JOIN vw_employee_month_list as eml ON employee_banking.employee_month_id = eml.employee_month_id
		INNER JOIN vw_bank_branch ON employee_banking.bank_branch_id = vw_bank_branch.bank_branch_id
		INNER JOIN currency ON employee_banking.currency_id = currency.currency_id;

CREATE VIEW vw_pension_adjustments AS
	SELECT c.period_id, c.start_date,
		a.employee_adjustment_id, a.employee_month_id, a.adjustment_id, a.pension_id, 
		a.org_id, a.adjustment_type, a.adjustment_factor, a.pay_date, a.amount, 
		a.exchange_rate, a.in_payroll, a.in_tax, a.visible,
		(a.amount * a.exchange_rate) as base_amount
	FROM employee_adjustments as a INNER JOIN employee_month as b ON a.employee_month_id = b.employee_month_id
		INNER JOIN periods as c ON b.period_id = c.period_id
	WHERE (a.pension_id is not null);

CREATE VIEW vw_employee_pensions AS
	SELECT a.entity_id, a.entity_name, a.adjustment_id, a.adjustment_name, a.contribution_id, 
		a.contribution_name, a.org_id, a.pension_id, a.pension_company, a.pension_number, 
		a.active, a.currency_id, a.currency_name, a.currency_symbol,
		b.period_id, b.start_date, b.employee_month_id, 
		COALESCE(b.amount, 0) as amount, 
		COALESCE(b.base_amount, 0) as base_amount,
		COALESCE(c.amount, 0) as employer_amount, 
		COALESCE(c.base_amount, 0) as employer_base_amount,
		(b.amount + COALESCE(c.amount, 0)) as pension_amount, 
		(b.base_amount + COALESCE(c.base_amount, 0)) as pension_base_amount
	FROM (vw_pensions as a INNER JOIN vw_pension_adjustments as b 
		ON (a.pension_id = b.pension_id) AND (a.adjustment_id = b.adjustment_id))
		LEFT JOIN vw_pension_adjustments as c
		ON (a.pension_id = c.pension_id) AND (a.contribution_id = c.adjustment_id)
		AND (b.employee_month_id = c.employee_month_id);
		
CREATE VIEW vw_employee_per_diem_ledger AS
	(SELECT vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, 'Transport' as description, 
		vw_employee_per_diem.post_account, vw_employee_per_diem.entity_name, vw_employee_per_diem.full_amount as dr_amt, 0.0 as cr_amt
	FROM vw_employee_per_diem
	WHERE (vw_employee_per_diem.approve_status = 'Approved'))
	UNION
	(SELECT vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, 'Travel Petty Cash' as description, 
		'3305', vw_employee_per_diem.entity_name, 0.0 as dr_amt, cash_paid as cr_amt
	FROM vw_employee_per_diem
	WHERE (vw_employee_per_diem.approve_status = 'Approved'))
	UNION
	(SELECT  vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, 'Transport PAYE' as description, 
		'4045', vw_employee_per_diem.entity_name, 0.0 as dr_amt, full_amount - cash_paid as cr_amt
	FROM vw_employee_per_diem
	WHERE (vw_employee_per_diem.approve_status = 'Approved'));

CREATE VIEW vw_payroll_ledger_trx AS
	SELECT org_id, period_id, end_date, description, gl_payroll_account, entity_name, employee_id,
		dr_amt, cr_amt 
	FROM 
	((SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, 'BASIC SALARY' as description, 
		vw_employee_month.gl_payroll_account, vw_employee_month.entity_name, vw_employee_month.employee_id,
		vw_employee_month.basic_pay as dr_amt, 0.0 as cr_amt
	FROM vw_employee_month)
	UNION
	(SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, 'SALARY PAYMENTS',
		vw_employee_month.gl_bank_account, vw_employee_month.entity_name, vw_employee_month.employee_id,
		0.0 as sum_basic_pay, 
		vw_employee_month.banked as sum_banked
	FROM vw_employee_month)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.tax_type_name, 
		vw_employee_tax_types.account_number, vw_employee_tax_types.entity_name, vw_employee_tax_types.employee_id,
		0.0, 
		(vw_employee_tax_types.amount + vw_employee_tax_types.additional + vw_employee_tax_types.employer) 
	FROM vw_employee_tax_types)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, 'Employer - ' || vw_employee_tax_types.tax_type_name, 
		vw_employee_tax_types.account_number, vw_employee_tax_types.entity_name, vw_employee_tax_types.employee_id,
		vw_employee_tax_types.employer, 0.0
	FROM vw_employee_tax_types
	WHERE (vw_employee_tax_types.employer <> 0))
	UNION
	(SELECT vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.adjustment_name, vw_employee_adjustments.account_number, 
		vw_employee_adjustments.entity_name, vw_employee_adjustments.employee_id,
		SUM(CASE WHEN vw_employee_adjustments.adjustment_type = 1 THEN vw_employee_adjustments.amount - vw_employee_adjustments.paid_amount ELSE 0 END) as dr_amt,
		SUM(CASE WHEN vw_employee_adjustments.adjustment_type = 2 THEN vw_employee_adjustments.amount - vw_employee_adjustments.paid_amount ELSE 0 END) as cr_amt
	FROM vw_employee_adjustments
	WHERE (vw_employee_adjustments.visible = true) AND (vw_employee_adjustments.adjustment_type < 3)
	GROUP BY vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.adjustment_name, vw_employee_adjustments.account_number, 
		vw_employee_adjustments.entity_name, vw_employee_adjustments.employee_id)
	UNION
	(SELECT vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, 'Transport' as description, 
		vw_employee_per_diem.post_account, vw_employee_per_diem.entity_name, vw_employee_per_diem.employee_id,
		(vw_employee_per_diem.full_amount - vw_employee_per_diem.Cash_paid) as dr_amt, 0.0 as cr_amt
	FROM vw_employee_per_diem
	WHERE (vw_employee_per_diem.approve_status = 'Approved'))
	UNION
	(SELECT ea.org_id, ea.period_id, ea.end_date, 'SALARY ADVANCE' as description, 
		ea.gl_payroll_account, ea.entity_name, ea.employee_id,
		ea.amount as dr_amt, 
		0.0 as cr_amt
	FROM vw_employee_advances as ea
	WHERE (ea.in_payroll = true))
	UNION
	(SELECT ead.org_id, ead.period_id, ead.end_date, 'ADVANCE DEDUCTION' as description, 
		ead.gl_payroll_account, ead.entity_name, ead.employee_id,
		0.0 as dr_amt, 
		ead.amount as cr_amt
	FROM vw_advance_deductions as ead
	WHERE (ead.in_payroll = true))) as a
	ORDER BY gl_payroll_account desc, dr_amt desc, cr_amt desc;

CREATE VIEW vw_payroll_ledger AS
	SELECT org_id, period_id, end_date, description, gl_payroll_account, dr_amt, cr_amt 
	FROM 
	((SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, 'BASIC SALARY' as description, 
		vw_employee_month.gl_payroll_account, 
		sum(vw_employee_month.basic_pay) as dr_amt, 
		0.0 as cr_amt
	FROM vw_employee_month
	GROUP BY vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.gl_payroll_account)
	UNION
	(SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, 'SALARY PAYMENTS',
		vw_employee_month.gl_bank_account, 0.0 as sum_basic_pay, sum(vw_employee_month.banked) as sum_banked
	FROM vw_employee_month
	GROUP BY vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.gl_bank_account)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.tax_type_name, 
		vw_employee_tax_types.account_number, 0.0, 
		sum(vw_employee_tax_types.amount + vw_employee_tax_types.additional + vw_employee_tax_types.employer) 
	FROM vw_employee_tax_types
	GROUP BY vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.tax_type_name, 
		vw_employee_tax_types.account_number)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, 'Employer - ' || vw_employee_tax_types.tax_type_name, 
		vw_employee_tax_types.account_number, SUM(vw_employee_tax_types.employer), 0.0
	FROM vw_employee_tax_types
	WHERE (vw_employee_tax_types.employer <> 0)
	GROUP BY vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.tax_type_name,
		vw_employee_tax_types.account_number)
	UNION
	(SELECT vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.adjustment_name, vw_employee_adjustments.account_number, 
		SUM(CASE WHEN vw_employee_adjustments.adjustment_type = 1 THEN vw_employee_adjustments.amount - vw_employee_adjustments.paid_amount ELSE 0 END) as dr_amt,
		SUM(CASE WHEN vw_employee_adjustments.adjustment_type = 2 THEN vw_employee_adjustments.amount - vw_employee_adjustments.paid_amount ELSE 0 END) as cr_amt
	FROM vw_employee_adjustments
	WHERE (vw_employee_adjustments.in_payroll = true) AND (vw_employee_adjustments.visible = true) AND (vw_employee_adjustments.adjustment_type < 3)
	GROUP BY vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.adjustment_name, 
		vw_employee_adjustments.account_number, vw_employee_adjustments.adjustment_type)
	UNION
	(SELECT vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, 'Transport' as description, 
		vw_employee_per_diem.post_account, 
		sum(vw_employee_per_diem.full_amount - vw_employee_per_diem.Cash_paid) as dr_amt, 0.0 as cr_amt
	FROM vw_employee_per_diem
	WHERE (vw_employee_per_diem.approve_status = 'Approved')
	GROUP BY vw_employee_per_diem.org_id, vw_employee_per_diem.period_id, vw_employee_per_diem.travel_date, vw_employee_per_diem.post_account)
	UNION
	(SELECT ea.org_id, ea.period_id, ea.end_date, 'SALARY ADVANCE' as description, 
		ea.gl_payroll_account, 
		sum(ea.amount) as dr_amt, 
		0.0 as cr_amt
	FROM vw_employee_advances as ea
	WHERE (ea.in_payroll = true)
	GROUP BY ea.org_id, ea.period_id, ea.end_date, ea.gl_payroll_account)
	UNION
	(SELECT ead.org_id, ead.period_id, ead.end_date, 'ADVANCE DEDUCTION' as description, 
		ead.gl_payroll_account, 
		0.0 as dr_amt, 
		sum(ead.amount) as cr_amt
	FROM vw_advance_deductions as ead
	WHERE (ead.in_payroll = true)
	GROUP BY ead.org_id, ead.period_id, ead.end_date, ead.gl_payroll_account)) as a
	ORDER BY gl_payroll_account desc, dr_amt desc, cr_amt desc;
	
CREATE VIEW vw_sun_ledger_trx AS
	SELECT org_id, period_id, end_date, entity_id,
		gl_payroll_account, description,
		department_account,  employee_id, function_code,
		description2, round(amount::numeric, 1) as gl_amount, debit_credit,
		(period_id::varchar || '.' || entity_id::varchar || '.' || COALESCE(gl_payroll_account, '')) as sun_ledger_id
	FROM 
	((SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.entity_id,
		vw_employee_month.gl_payroll_account, 'Payroll' as description, 
		departments.department_account, vw_employee_month.employee_id, departments.function_code,
		to_char(vw_employee_month.start_date, 'Month YYYY') || ' - Basic Pay' as description2, 
		vw_employee_month.basic_pay as amount,
		'D' as debit_credit
	FROM vw_employee_month INNER JOIN departments ON vw_employee_month.department_id = departments.department_id)
	UNION
	(SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.entity_id,
		vw_employee_month.employee_id, vw_employee_month.entity_name,
		'', '', '',
		to_char(vw_employee_month.start_date, 'Month YYYY') || ' - Netpay' as description2, 
		net_pay as amount,
		'C' as debit_credit
	FROM vw_employee_month)
	UNION
	(SELECT vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.entity_id,
		vw_employee_adjustments.account_number, vw_employee_adjustments.adjustment_name, 
		vw_employee_adjustments.department_account, vw_employee_adjustments.employee_id, vw_employee_adjustments.function_code,
		to_char(vw_employee_adjustments.start_date, 'Month YYYY') || ' - ' || vw_employee_adjustments.adjustment_name as description2, 
			
		sum(vw_employee_adjustments.amount),
		'D' as debit_credit
	FROM vw_employee_adjustments
	WHERE (vw_employee_adjustments.visible = true) AND (vw_employee_adjustments.adjustment_type = 1)
	GROUP BY vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.entity_id,
		vw_employee_adjustments.account_number, vw_employee_adjustments.adjustment_name, 
		vw_employee_adjustments.department_account, vw_employee_adjustments.employee_id, vw_employee_adjustments.function_code,
		vw_employee_adjustments.start_date)
	UNION
	(SELECT vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.entity_id,
		vw_employee_adjustments.account_number, vw_employee_adjustments.adjustment_name, 
		vw_employee_adjustments.department_account, vw_employee_adjustments.employee_id, vw_employee_adjustments.function_code,
		to_char(vw_employee_adjustments.start_date, 'Month YYYY') || ' - ' || vw_employee_adjustments.adjustment_name as description2, 
			
		sum(vw_employee_adjustments.amount),
		'C' as debit_credit
	FROM vw_employee_adjustments
	WHERE (vw_employee_adjustments.visible = true) AND (vw_employee_adjustments.adjustment_type = 2)
	GROUP BY vw_employee_adjustments.org_id, vw_employee_adjustments.period_id, vw_employee_adjustments.end_date, vw_employee_adjustments.entity_id,
		vw_employee_adjustments.account_number, vw_employee_adjustments.adjustment_name, 
		vw_employee_adjustments.department_account, vw_employee_adjustments.employee_id, vw_employee_adjustments.function_code,
		vw_employee_adjustments.start_date)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.entity_id,
		vw_employee_tax_types.account_number, vw_employee_tax_types.tax_type_name,
		vw_employee_tax_types.department_account, vw_employee_tax_types.employee_id, vw_employee_tax_types.function_code,
		to_char(vw_employee_tax_types.start_date, 'Month YYYY') || ' - ' || vw_employee_tax_types.tax_type_name || ' - Deduction',
		(vw_employee_tax_types.amount + vw_employee_tax_types.additional + vw_employee_tax_types.employer),
		'C' as debit_credit
	FROM vw_employee_tax_types)
	UNION
	(SELECT vw_employee_tax_types.org_id, vw_employee_tax_types.period_id, vw_employee_tax_types.end_date, vw_employee_tax_types.entity_id,
		vw_employee_tax_types.employer_account, vw_employee_tax_types.tax_type_name,
		vw_employee_tax_types.department_account, vw_employee_tax_types.employee_id, vw_employee_tax_types.function_code,
		to_char(vw_employee_tax_types.start_date, 'Month YYYY') || ' - ' || vw_employee_tax_types.tax_type_name || ' - Contribution',
		vw_employee_tax_types.employer,
		'D' as debit_credit
	FROM vw_employee_tax_types
	WHERE vw_employee_tax_types.employer > 0)
	UNION
	(SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.entity_id,
		vw_employee_month.employee_id, vw_employee_month.entity_name,
		'', '', '',
		to_char(vw_employee_month.start_date, 'Month YYYY') || ' - Payroll Banking' as description2, 
		banked as amount,
		'D' as debit_credit
	FROM vw_employee_month)
	UNION
	(SELECT vw_employee_month.org_id, vw_employee_month.period_id, vw_employee_month.end_date, vw_employee_month.entity_id,
		vw_employee_month.gl_bank_account, 'Bank Account',
		'', '', '',
		to_char(vw_employee_month.start_date, 'Month YYYY') || ' - Payroll Banking' as description2, 
		banked as amount,
		'C' as debit_credit
	FROM vw_employee_month)) as a
	ORDER BY gl_payroll_account desc, amount desc, debit_credit desc;
	

CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON employee_overtime
    FOR EACH ROW EXECUTE PROCEDURE upd_action();

CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON employee_per_diem
    FOR EACH ROW EXECUTE PROCEDURE upd_action();

CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON claims
    FOR EACH ROW EXECUTE PROCEDURE upd_action();

CREATE OR REPLACE FUNCTION ins_taxes() RETURNS trigger AS $$
BEGIN
	INSERT INTO default_tax_types (org_id, entity_id, tax_type_id)
	SELECT NEW.org_id, NEW.entity_id, tax_type_id
	FROM tax_types
	WHERE (active = true) AND (use_key = 1) AND (org_id = NEW.org_id);

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_taxes AFTER INSERT ON employees
    FOR EACH ROW EXECUTE PROCEDURE ins_taxes();

CREATE OR REPLACE FUNCTION ins_bf_periods() RETURNS trigger AS $$
DECLARE
	rec RECORD;
BEGIN
	SELECT bank_header, bank_address INTO rec
	FROM orgs
	WHERE (org_id = NEW.org_id);

	NEW.bank_header = rec.bank_header;
	NEW.bank_address = rec.bank_address;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_bf_periods BEFORE INSERT ON periods
    FOR EACH ROW EXECUTE PROCEDURE ins_bf_Periods();
    

CREATE OR REPLACE FUNCTION get_formula_adjustment(int, int, real) RETURNS float AS $$
DECLARE
	v_employee_month_id		integer;
	v_basic_pay				float;
	v_adjustment			float;
BEGIN

	SELECT employee_month.employee_month_id, employee_month.basic_pay INTO v_employee_month_id, v_basic_pay
	FROM employee_month
	WHERE (employee_month.employee_month_id = $1);

	IF ($2 = 1) THEN
		v_adjustment := v_basic_pay * $3;
	ELSE
		v_adjustment := 0;
	END IF;

	IF(v_adjustment is null) THEN
		v_adjustment := 0;
	END IF;

	RETURN v_adjustment;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_payroll(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	v_period_id		integer;
	v_org_id		integer;
	v_month_name	varchar(50);

	msg 			varchar(120);
BEGIN
	SELECT period_id, org_id, to_char(start_date, 'Month YYYY') INTO v_period_id, v_org_id, v_month_name
	FROM periods
	WHERE (period_id = CAST($1 as integer));

	INSERT INTO period_tax_types (period_id, org_id, tax_type_id, period_tax_type_name, formural, tax_relief, percentage, linear, employer, employer_ps, tax_type_order, in_tax, account_id)
	SELECT v_period_id, org_id, tax_type_id, tax_type_name, formural, tax_relief, percentage, linear, employer, employer_ps, tax_type_order, in_tax, account_id
	FROM tax_types
	WHERE (active = true) AND (org_id = v_org_id);

	INSERT INTO employee_month (period_id, org_id, pay_group_id, entity_id, bank_branch_id, department_role_id, currency_id, bank_account, basic_pay)
	SELECT v_period_id, org_id, pay_group_id, entity_id, bank_branch_id, department_role_id, currency_id, bank_account, basic_salary
	FROM employees
	WHERE (employees.active = true) and (employees.org_id = v_org_id);

	INSERT INTO loan_monthly (period_id, org_id, loan_id, repayment, interest_amount, interest_paid)
	SELECT v_period_id, org_id, loan_id, monthly_repayment, (loan_balance * interest / 1200), (loan_balance * interest / 1200)
	FROM vw_loans 
	WHERE (loan_balance > 0) AND (approve_status = 'Approved') AND (reducing_balance =  true) AND (org_id = v_org_id);

	INSERT INTO loan_monthly (period_id, org_id, loan_id, repayment, interest_amount, interest_paid)
	SELECT v_period_id, org_id, loan_id, monthly_repayment, (principle * interest / 1200), (principle * interest / 1200)
	FROM vw_loans 
	WHERE (loan_balance > 0) AND (approve_status = 'Approved') AND (reducing_balance =  false) AND (org_id = v_org_id);

	PERFORM updTax(employee_month_id, Period_id)
	FROM employee_month
	WHERE (period_id = v_period_id);
	
	INSERT INTO sys_emailed (sys_email_id, table_id, table_name, narrative, org_id)
	SELECT 7, entity_id, 'periods', v_month_name, v_org_id
	FROM entity_subscriptions
	WHERE entity_type_id = 6;

	msg := 'Payroll Generated';

	RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_period_tax_types() RETURNS trigger AS $$
BEGIN
	INSERT INTO period_tax_rates (org_id, period_tax_type_id, tax_range, tax_rate)
	SELECT NEW.org_id, NEW.period_tax_type_id, tax_range, tax_rate
	FROM tax_rates
	WHERE (tax_type_id = NEW.tax_type_id);

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_period_tax_types AFTER INSERT ON period_tax_types
    FOR EACH ROW EXECUTE PROCEDURE ins_period_tax_types();
    
CREATE OR REPLACE FUNCTION ins_employee_month() RETURNS trigger AS $$
BEGIN

	SELECT exchange_rate INTO NEW.exchange_rate
	FROM currency_rates
	WHERE (currency_rate_id = 
		(SELECT MAX(currency_rate_id)
		FROM currency_rates
		WHERE (currency_id = NEW.currency_id) AND (org_id = NEW.org_id)
			AND (exchange_date < CURRENT_DATE)));
		
	IF(NEW.exchange_rate is null)THEN NEW.exchange_rate := 1; END IF;	

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_employee_month BEFORE INSERT ON employee_month
    FOR EACH ROW EXECUTE PROCEDURE ins_employee_month();

CREATE OR REPLACE FUNCTION upd_employee_month() RETURNS trigger AS $$
BEGIN
	INSERT INTO employee_tax_types (org_id, employee_month_id, tax_type_id, tax_identification, additional, amount, employer, in_tax, exchange_rate)
	SELECT NEW.org_id, NEW.employee_month_id, default_tax_types.tax_type_id, default_tax_types.tax_identification, 
		Default_Tax_Types.Additional, 0, 0, Tax_Types.In_Tax,
		(CASE WHEN Tax_Types.currency_id = NEW.currency_id THEN 1 ELSE 1 / NEW.exchange_rate END)
	FROM Default_Tax_Types INNER JOIN Tax_Types ON Default_Tax_Types.Tax_Type_id = Tax_Types.Tax_Type_id
	WHERE (Default_Tax_Types.active = true) AND (Default_Tax_Types.entity_ID = NEW.entity_ID);

	INSERT INTO employee_adjustments (org_id, employee_month_id, adjustment_id, amount, adjustment_type, in_payroll, in_tax, visible, adjustment_factor, 
		balance, tax_relief_amount, exchange_rate, narrative)
	SELECT NEW.org_id, NEW.employee_month_id, default_adjustments.adjustment_id, default_adjustments.amount,
		adjustments.adjustment_type, adjustments.in_payroll, adjustments.in_tax, adjustments.visible,
		(CASE WHEN adjustments.adjustment_type = 2 THEN -1 ELSE 1 END),
		(CASE WHEN (adjustments.running_balance = true) AND (adjustments.reduce_balance = false) THEN (default_adjustments.balance + default_adjustments.amount)
			WHEN (adjustments.running_balance = true) AND (adjustments.reduce_balance = true) THEN (default_adjustments.balance - default_adjustments.amount) END),
		(default_adjustments.amount * adjustments.tax_relief_ps / 100),
		(CASE WHEN adjustments.currency_id = NEW.currency_id THEN 1 ELSE 1 / NEW.exchange_rate END),
		narrative
	FROM default_adjustments INNER JOIN adjustments ON default_adjustments.adjustment_id = adjustments.adjustment_id
	WHERE ((default_adjustments.final_date is null) OR (default_adjustments.final_date > current_date))
		AND (default_adjustments.active = true) AND (default_adjustments.entity_id = NEW.entity_id);

	INSERT INTO advance_deductions (org_id, amount, employee_month_id)
	SELECT NEW.org_id, (Amount / Pay_Period), NEW.Employee_Month_ID
	FROM employee_advances INNER JOIN employee_month ON employee_advances.employee_month_id = employee_month.employee_month_id
	WHERE (employee_month.entity_id = NEW.entity_id) AND (employee_advances.pay_period > 0) AND (employee_advances.completed = false)
		AND (employee_advances.pay_upto >= current_date);
		
	INSERT INTO project_staff_costs (org_id, employee_month_id, project_id, project_role, payroll_ps, staff_cost, tax_cost)
	SELECT NEW.org_id, NEW.employee_month_id, 
		project_staff.project_id, project_staff.project_role, project_staff.payroll_ps, project_staff.staff_cost, project_staff.tax_cost
	FROM project_staff
	WHERE (project_staff.entity_id = NEW.entity_id) AND (project_staff.monthly_cost = true);
	
	INSERT INTO employee_banking (org_id, employee_month_id, bank_branch_id, currency_id, 
		bank_account, amount, 
		exchange_rate)
	SELECT NEW.org_id, NEW.employee_month_id, bank_branch_id, currency_id,
		bank_account, amount,
		(CASE WHEN default_banking.currency_id = NEW.currency_id THEN 1 ELSE 1 / NEW.exchange_rate END)
	FROM default_banking 
	WHERE (default_banking.entity_id = NEW.entity_id) AND (default_banking.active = true)
		AND (amount > 0);

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_employee_month AFTER INSERT ON employee_month
    FOR EACH ROW EXECUTE PROCEDURE upd_employee_month();

CREATE OR REPLACE FUNCTION gettax(float, int) RETURNS float AS $$
DECLARE
	reca		RECORD;
	tax			REAL;
BEGIN
	SELECT period_tax_type_id, formural, tax_relief, percentage, linear, in_tax, employer, employer_ps INTO reca
	FROM period_tax_types
	WHERE (period_tax_type_id = $2);

	IF(reca.linear = true) THEN
		SELECT SUM(CASE WHEN tax_range < $1 
		THEN (tax_rate / 100) * (tax_range - getTaxMin(tax_range, reca.period_tax_type_id)) 
		ELSE (tax_rate / 100) * ($1 - getTaxMin(tax_range, reca.period_tax_type_id)) END) INTO tax
		FROM period_tax_rates 
		WHERE (getTaxMin(tax_range, reca.period_tax_type_id) <= $1) AND (period_tax_type_id = reca.period_tax_type_id);
	ELSIF(reca.linear = false) THEN 
		SELECT max(tax_rate) INTO tax
		FROM period_tax_rates 
		WHERE (getTaxMin(tax_range, reca.period_tax_type_id) < $1) AND (tax_range >= $1) 
			AND (period_tax_type_id = reca.period_tax_type_id);
	END IF;

	IF (tax is null) THEN
		tax := 0;
	END IF;

	IF (tax > reca.tax_relief) THEN
		tax := tax - reca.tax_relief;
	ELSE
		tax := 0;
	END IF;

	RETURN tax;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_employee_tax(int, int) RETURNS float AS $$
DECLARE
	v_employee_month_id			integer;
	v_period_tax_type_id		integer;
	v_exchange_rate				real;
	v_income					real;
	v_tax_relief				real;
	v_tax						real;
BEGIN

	SELECT employee_tax_types.employee_month_id, period_tax_types.period_tax_type_id, employee_tax_types.exchange_rate
		INTO v_employee_month_id, v_period_tax_type_id, v_exchange_rate
	FROM employee_tax_types INNER JOIN employee_month ON employee_tax_types.employee_month_id = employee_month.employee_month_id
		INNER JOIN period_tax_types ON (employee_month.period_id = period_tax_types.period_id)
			AND (employee_tax_types.tax_type_id = period_tax_types.tax_type_id)
	WHERE (employee_tax_types.employee_tax_type_id	= $1);
	
	IF(v_exchange_rate = 0) THEN v_exchange_rate := 1; END IF;

	IF ($2 = 1) THEN
		v_income := getAdjustment(v_employee_month_id, 1) / v_exchange_rate;
		v_tax := getTax(v_income, v_period_tax_type_id);

	ELSIF ($2 = 2) THEN
		v_income := getAdjustment(v_employee_month_id, 2) / v_exchange_rate;
		v_tax := getTax(v_income, v_period_tax_type_id) - getAdjustment(v_employee_month_id, 4, 25) / v_exchange_rate;

	ELSIF ($2 = 3) THEN
		v_income := getAdjustment(v_employee_month_id, 2) / v_exchange_rate;
		v_tax_relief := getAdjustment(v_employee_month_id, 1) / 100;
		if(v_tax_relief < 16666.67) then v_tax_relief := 16666.67; end if;
		v_tax_relief := v_tax_relief + getAdjustment(v_employee_month_id, 1) / 5;
		v_income := v_income - v_tax_relief;
		v_tax := getTax(v_income, v_period_tax_type_id) - getAdjustment(v_employee_month_id, 4, 25) / v_exchange_rate;

	ELSE
		v_tax := 0;
	END IF;

	IF(v_tax is null) THEN
		v_tax := 0;
	END IF;

	RETURN v_tax;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updtax(int, int) RETURNS float AS $$
DECLARE
	reca 				RECORD;
	income 				REAL;
	tax 				REAL;
	InsuranceRelief 	REAL;
BEGIN

	FOR reca IN SELECT employee_tax_types.employee_tax_type_id, employee_tax_types.tax_type_id, period_tax_types.formural,
			 period_tax_types.employer, period_tax_types.employer_ps
		FROM employee_tax_types INNER JOIN period_tax_types ON (employee_tax_types.tax_type_id = period_tax_types.tax_type_id)
		WHERE (employee_month_id = $1) AND (Period_Tax_Types.Period_ID = $2)
		ORDER BY Period_Tax_Types.Tax_Type_order LOOP

		EXECUTE 'SELECT ' || reca.formural || ' FROM employee_tax_types WHERE employee_tax_type_id = ' || reca.employee_tax_type_id 
		INTO tax;

		UPDATE employee_tax_types SET amount = tax, employer = reca.employer + (tax * reca.employer_ps / 100)
		WHERE employee_tax_type_id = reca.employee_tax_type_id;
	END LOOP;

	RETURN tax;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_payroll(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	rec 		RECORD;
	msg 		varchar(120);
BEGIN
	IF ($3 = '1') THEN
		UPDATE employee_adjustments SET tax_reduction_amount = 0 
		FROM employee_month 
		WHERE (employee_adjustments.employee_month_id = employee_month.employee_month_id) 
			AND (employee_month.period_id = CAST($1 as int));
	
		PERFORM updTax(employee_month_id, period_id)
		FROM employee_month
		WHERE (period_id = CAST($1 as int));

		msg := 'Payroll Processed';
	ELSIF ($3 = '2') THEN
		UPDATE periods SET entity_id = CAST($2 as int), approve_status = 'Completed'
		WHERE (period_id = CAST($1 as int));

		msg := 'Application for approval';
	ELSIF ($3 = '3') THEN
		UPDATE periods SET closed = true
		WHERE (period_id = CAST($1 as int));

		msg := 'Application for approval';
	ELSIF ($3 = '4') THEN
		UPDATE periods SET closed = false
		WHERE (period_id = CAST($1 as int));

		msg := 'Application for approval';
	END IF;

	return msg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ins_employee_adjustments() RETURNS trigger AS $$
DECLARE
	v_formural					varchar(430);
	v_tax_relief_ps				float;
	v_tax_reduction_ps			float;
	v_tax_max_allowed			float;
BEGIN
	IF((NEW.Amount = 0) AND (NEW.paid_amount <> 0))THEN
		NEW.Amount = NEW.paid_amount / 0.7;
	END IF;
	
	IF(NEW.exchange_rate is null) THEN NEW.exchange_rate = 1; END IF;
	IF(NEW.exchange_rate = 0) THEN NEW.exchange_rate = 1; END IF;

	SELECT adjustment_type, formural INTO NEW.adjustment_type, v_formural
	FROM adjustments 
	WHERE (adjustments.adjustment_id = NEW.adjustment_id);
	
	IF(NEW.adjustment_type = 2)THEN
		NEW.adjustment_factor = -1;
	END IF;
	
	IF(NEW.Amount = 0) and (v_formural is not null)THEN
		EXECUTE 'SELECT ' || v_formural || ' FROM employee_month WHERE employee_month_id = ' || NEW.employee_month_id
		INTO NEW.Amount;
		NEW.Amount := NEW.Amount / NEW.exchange_rate;
	END IF;

	IF(NEW.in_tax = true)THEN
		SELECT tax_reduction_ps, tax_relief_ps, tax_max_allowed INTO v_tax_reduction_ps, v_tax_relief_ps, v_tax_max_allowed
		FROM adjustments
		WHERE (adjustments.adjustment_id = NEW.adjustment_id);

		IF(v_tax_reduction_ps is null)THEN
			NEW.tax_reduction_amount := 0;
		ELSE
			NEW.tax_reduction_amount := NEW.amount * v_tax_reduction_ps / 100;
			NEW.tax_reduction_amount := NEW.tax_reduction_amount;
		END IF;

		IF(v_tax_relief_ps is null)THEN
			NEW.tax_relief_amount := 0;
		ELSE
			NEW.tax_relief_amount := NEW.amount * v_tax_relief_ps / 100;
			NEW.tax_relief_amount := NEW.tax_relief_amount;
		END IF;

		IF(v_tax_max_allowed is not null)THEN
			IF(NEW.tax_reduction_amount > v_tax_max_allowed)THEN
				NEW.tax_reduction_amount := v_tax_max_allowed;
			END IF;
			IF(NEW.tax_relief_amount > v_tax_max_allowed)THEN
				NEW.tax_relief_amount := v_tax_max_allowed;
			END IF;
		END IF;
	ELSE
		NEW.tax_relief_amount := 0;
		NEW.tax_reduction_amount := 0;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_Employee_Adjustments BEFORE INSERT OR UPDATE ON Employee_Adjustments
    FOR EACH ROW EXECUTE PROCEDURE ins_Employee_Adjustments();

CREATE OR REPLACE FUNCTION upd_employee_adjustments() RETURNS trigger AS $$
DECLARE
	rec 		RECORD;
	entityid 	integer;
	periodid 	integer;
BEGIN
	SELECT monthly_update, running_balance INTO rec
	FROM adjustments WHERE adjustment_id = NEW.Adjustment_ID;

	SELECT entity_id, period_id INTO entityid, periodid
	FROM employee_month WHERE employee_month_id = NEW.employee_month_id;

	IF(rec.running_balance = true) AND (NEW.balance is not null)THEN
		UPDATE default_adjustments SET balance = NEW.balance
		WHERE (entity_id = entityid) AND (adjustment_id = NEW.adjustment_id);
	END IF;

	IF(TG_OP = 'UPDATE')THEN
		IF (OLD.amount <> NEW.amount)THEN
			IF(rec.monthly_update = true)THEN
				UPDATE default_adjustments SET amount = NEW.amount 
				WHERE (entity_id = entityid) AND (adjustment_id = NEW.adjustment_id);
			END IF;

			PERFORM updTax(employee_month_id, Period_id)
			FROM employee_month
			WHERE (period_id = periodid);
		END IF;
	ELSE
		PERFORM updTax(employee_month_id, Period_id)
		FROM employee_month
		WHERE (period_id = periodid);
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_employee_adjustments AFTER INSERT OR UPDATE ON employee_adjustments
    FOR EACH ROW EXECUTE PROCEDURE upd_employee_adjustments();

CREATE OR REPLACE FUNCTION upd_employee_per_diem() RETURNS trigger AS $$
DECLARE
	periodid integer;
	taxLimit real;
BEGIN
	SELECT Periods.Period_ID, Periods.Per_Diem_tax_limit INTO periodid, taxLimit
	FROM Employee_Month INNER JOIN Periods ON Employee_Month.Period_id = Periods.Period_id
	WHERE Employee_Month_ID = NEW.Employee_Month_ID;

	IF(NEW.Cash_paid = 0) THEN
		NEW.Cash_paid := NEW.Per_Diem;
	END IF;
	IF(NEW.tax_amount = 0) THEN
		NEW.full_amount := (NEW.Per_Diem - (taxLimit * NEW.days_travelled * 0.3)) / 0.7;
		NEW.tax_amount := NEW.full_amount - (taxLimit * NEW.days_travelled);
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_Employee_Per_Diem BEFORE INSERT OR UPDATE ON Employee_Per_Diem
    FOR EACH ROW EXECUTE PROCEDURE upd_Employee_Per_Diem();

CREATE OR REPLACE FUNCTION process_ledger(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	isposted boolean;
	ledger_diff real;
	msg varchar(120);
BEGIN

	SELECT is_posted INTO isposted
	FROM Periods
	WHERE (period_id = CAST($1 as int));

	SELECT abs(sum(dr_amt) - sum(cr_amt)) INTO ledger_diff
	FROM vw_payroll_ledger
	WHERE (period_id = CAST($1 as int));

	msg := 'Payroll Ledger not posted';
	IF((isposted = false) AND (ledger_diff < 5)) THEN
		INSERT INTO payroll_ledger (period_id, posting_date, description, payroll_account, dr_amt, cr_amt)
		SELECT period_id, end_date, description, gl_payroll_account, ROUND(CAST(dr_amt as numeric), 2), ROUND(CAST(cr_amt as numeric), 2)
		FROM vw_payroll_ledger
		WHERE (period_id = CAST($1 as int));

		UPDATE Periods SET is_posted = true
		WHERE (period_id = CAST($1 as int));

		msg := 'Payroll Ledger Processed';
	END IF;

	return msg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION del_period(int) RETURNS varchar(120) AS $$
DECLARE
	msg 		varchar(120);
BEGIN
	DELETE FROM loan_monthly WHERE period_id = $1;
	
	DELETE FROM advance_deductions WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM employee_advances WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM employee_banking WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM employee_adjustments WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM employee_overtime WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM employee_tax_types WHERE (employee_month_id IN (SELECT employee_month_id FROM employee_month WHERE period_id = $1));
	DELETE FROM period_tax_rates WHERE (period_tax_type_id IN (SELECT period_tax_type_id FROM period_tax_types WHERE period_id = $1));
	DELETE FROM period_tax_types WHERE period_id = $1;

	DELETE FROM employee_month WHERE period_id = $1;
	DELETE FROM periods WHERE period_id = $1;

	msg := 'Period Deleted';

	return msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_payroll(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	v_entity_id		integer;
	v_pay_step_id	integer;
	v_pay_step		integer;
	v_next_step_id	integer;
	v_pay_scale_id	integer;
	v_currency_id	integer;
	v_pay_amount	real;
	msg 			varchar(120);
BEGIN

	v_entity_id := CAST($1 as int);
	
	IF ($3 = '1') THEN
		SELECT pay_scale_steps.pay_scale_step_id, pay_scale_steps.pay_amount, pay_scales.currency_id
			INTO v_pay_step_id, v_pay_amount, v_currency_id
		FROM employees INNER JOIN pay_scale_steps ON employees.pay_scale_step_id = pay_scale_steps.pay_scale_step_id
			INNER JOIN pay_scales ON pay_scale_steps.pay_scale_id = pay_scales.pay_scale_id
		WHERE employees.entity_id = v_entity_id;
		
		IF((v_pay_amount is not null) AND (v_currency_id is not null))THEN
			UPDATE employees SET basic_salary = v_pay_amount, currency_id = v_currency_id
			WHERE entity_id = v_entity_id;
		END IF;

		msg := 'Updated the pay';
	ELSIF ($3 = '2') THEN
		SELECT pay_scale_steps.pay_scale_step_id, pay_scale_steps.pay_scale_id, pay_scale_steps.pay_step
			INTO v_pay_step_id, v_pay_scale_id, v_pay_step
		FROM employees INNER JOIN pay_scale_steps ON employees.pay_scale_step_id = pay_scale_steps.pay_scale_step_id
		WHERE employees.entity_id = v_entity_id;
		
		SELECT pay_scale_steps.pay_scale_step_id INTO v_next_step_id
		FROM pay_scale_steps
		WHERE (pay_scale_steps.pay_scale_id = v_pay_scale_id) AND (pay_scale_steps.pay_step = v_pay_step + 1);
		
		IF(v_next_step_id is not null)THEN
			UPDATE employees SET pay_scale_step_id = v_next_step_id
			WHERE entity_id = v_entity_id;
		END IF;

		msg := 'Pay step incremented';
	END IF;

	RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_adjustment(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	adj							RECORD;
	rec							RECORD;
	v_period_id					integer;
	v_org_id					integer;
	v_adjustment_factor			integer;
	v_default_adjustment_id		integer;
	v_amount					real;
	msg							varchar(120);
BEGIN

	SELECT adjustment_id, adjustment_name, org_id, adjustment_type, formural, default_amount, in_payroll, in_tax, visible INTO adj
	FROM adjustments
	WHERE (adjustment_id = $1::integer);
	
	IF(adj.adjustment_type = 2)THEN
		v_adjustment_factor := -1;
	ELSE
		v_adjustment_factor := 1;
	END IF;
	
	IF ($3 = '1') THEN
		SELECT max(period_id) INTO v_period_id
		FROM periods
		WHERE (closed = false) AND (org_id = adj.org_id);
		
		FOR rec IN SELECT employee_month_id, exchange_rate
			FROM employee_month 
			WHERE (period_id = v_period_id) LOOP
			
			IF(adj.formural is not null)THEN
				EXECUTE 'SELECT ' || adj.formural || ' FROM employee_month WHERE employee_month_id = ' || rec.employee_month_id
				INTO v_amount;
			END IF;
			IF(v_amount is null)THEN
				v_amount := adj.default_amount;
			END IF;
	
			IF(v_amount is not null)THEN
				INSERT INTO employee_adjustments (employee_month_id, adjustment_id, org_id,
					adjustment_type, adjustment_factor, pay_date, amount,
					exchange_rate, in_payroll, in_tax, visible)
				VALUES(rec.employee_month_id, adj.adjustment_id, adj.org_id,
					adj.adjustment_type, v_adjustment_factor, current_date, v_amount,
				(1 / rec.exchange_rate), adj.in_payroll, adj.in_tax, adj.visible);
			END IF;
		END LOOP;
		msg := 'Added ' || adj.adjustment_name || ' to month';
	ELSIF ($3 = '2') THEN	
		FOR rec IN SELECT entity_id
			FROM employees
			WHERE (active = true) AND (org_id = adj.org_id) LOOP
			
			SELECT default_adjustment_id INTO v_default_adjustment_id
			FROM default_adjustments
			WHERE (entity_id = rec.entity_id) AND (adjustment_id = adj.adjustment_id);
			
			IF(v_default_adjustment_id is null)THEN
				INSERT INTO default_adjustments (entity_id, adjustment_id, org_id,
					amount, active)
				VALUES (rec.entity_id, adj.adjustment_id, adj.org_id,
					adj.default_amount, true);
			END IF;
		END LOOP;
		msg := 'Added ' || adj.adjustment_name || ' to employees';
	END IF;

	RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_pensions(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	rec							RECORD;
	adj							RECORD;
	v_period_id					integer;
	v_org_id					integer;
	v_employee_month_id			integer;
	v_employee_adjustment_id	integer;
	v_currency_id				integer;
	v_exchange_rate				real;
	a_exchange_rate				real;
	v_amount					real;
	msg							varchar(120);
BEGIN

	SELECT period_id, org_id INTO v_period_id, v_org_id
	FROM periods WHERE period_id = $1::int;
	
	FOR rec IN SELECT pension_id, entity_id, adjustment_id, contribution_id, 
       pension_company, pension_number, amount, use_formura, 
       employer_ps, employer_amount, employer_formural
	FROM pensions WHERE (active = true) AND (org_id = v_org_id) LOOP
	
		SELECT employee_month_id, currency_id, exchange_rate 
			INTO v_employee_month_id, v_currency_id, v_exchange_rate
		FROM employee_month
		WHERE (period_id = v_period_id) AND (entity_id = rec.entity_id);
		
		--- Deduction
		SELECT employee_adjustment_id INTO v_employee_adjustment_id
		FROM employee_adjustments
		WHERE (employee_month_id = v_employee_month_id) AND (pension_id = rec.pension_id)
			AND (adjustment_id = rec.adjustment_id);
		
		SELECT adjustment_id, currency_id, org_id, adjustment_name, adjustment_type, 
			adjustment_order, earning_code, formural, monthly_update, in_payroll, 
			in_tax, visible, running_balance, reduce_balance, tax_reduction_ps, 
			tax_relief_ps, tax_max_allowed, account_number
		INTO adj
		FROM adjustments
		WHERE (adjustment_id = rec.adjustment_id);
		
		v_amount := 0;
		IF(rec.use_formura = true) AND (adj.formural is not null) AND (v_employee_month_id is not null) THEN
			EXECUTE 'SELECT ' || adj.formural || ' FROM employee_month WHERE employee_month_id = ' || v_employee_month_id
			INTO v_amount;
			IF(v_currency_id <> adj.currency_id)THEN
				v_amount := v_amount * v_exchange_rate;
			END IF;
		ELSIF(rec.amount > 0)THEN
			v_amount := rec.amount;
		END IF;
		
		a_exchange_rate := v_exchange_rate;
		IF(v_currency_id <> adj.currency_id)THEN
			a_exchange_rate := 1 / v_exchange_rate;
		END IF;
		
		IF(v_employee_adjustment_id is null) AND (v_employee_month_id is not null) THEN
			INSERT INTO employee_adjustments(employee_month_id, pension_id, org_id, 
				adjustment_id, adjustment_type, adjustment_factor, 
				in_payroll, in_tax, visible,
				exchange_rate, pay_date, amount)
			VALUES (v_employee_month_id, rec.pension_id, v_org_id,
				adj.adjustment_id, adj.adjustment_type, -1, 
				adj.in_payroll, adj.in_tax, adj.visible,
				a_exchange_rate, current_date, v_amount);
		ELSIF (v_employee_month_id is not null) THEN
			UPDATE employee_adjustments SET amount = v_amount, exchange_rate = a_exchange_rate
			WHERE employee_adjustment_id = v_employee_adjustment_id;
		END IF;
	
		--- Employer contribution
		IF((rec.employer_ps > 0) OR (rec.employer_amount > 0) OR (rec.employer_formural = true))THEN
			SELECT employee_adjustment_id INTO v_employee_adjustment_id
			FROM employee_adjustments
			WHERE (employee_month_id = v_employee_month_id) AND (pension_id = rec.pension_id)
				AND (adjustment_id = rec.contribution_id);
			
			SELECT adjustment_id, currency_id, org_id, adjustment_name, adjustment_type, 
				adjustment_order, earning_code, formural, monthly_update, in_payroll, 
				in_tax, visible, running_balance, reduce_balance, tax_reduction_ps, 
				tax_relief_ps, tax_max_allowed, account_number
			INTO adj
			FROM adjustments
			WHERE (adjustment_id = rec.contribution_id);
			
			IF(v_currency_id <> adj.currency_id)THEN
				a_exchange_rate := 1 / v_exchange_rate;
			END IF;
			
			v_amount := 0;
			IF(rec.employer_formural = true) AND (adj.formural is not null) AND (v_employee_month_id is not null) THEN
				EXECUTE 'SELECT ' || adj.formural || ' FROM employee_month WHERE employee_month_id = ' || v_employee_month_id
				INTO v_amount;
				IF(v_currency_id <> adj.currency_id)THEN
					v_amount := v_amount * v_exchange_rate;
				END IF;
			ELSIF(rec.employer_ps > 0)THEN
				v_amount := v_amount * rec.employer_ps / 100;
			ELSIF(rec.employer_amount > 0)THEN
				v_amount := rec.employer_amount;
			END IF;
			
			IF(v_employee_adjustment_id is null) AND (v_employee_month_id is not null) AND (v_amount > 0) THEN
				INSERT INTO employee_adjustments(employee_month_id, pension_id, org_id, 
					adjustment_id, adjustment_type, adjustment_factor, 
					in_payroll, in_tax, visible,
					exchange_rate, pay_date, amount)
				VALUES (v_employee_month_id, rec.pension_id, v_org_id,
					adj.adjustment_id, adj.adjustment_type, 1, 
					adj.in_payroll, adj.in_tax, adj.visible,
					a_exchange_rate, current_date, v_amount);
			ELSIF (v_employee_month_id is not null) THEN
				UPDATE employee_adjustments SET amount = v_amount, exchange_rate = a_exchange_rate
				WHERE employee_adjustment_id = v_employee_adjustment_id;
			END IF;
		END IF;
		
	END LOOP;

	msg := 'Pension Processed';

	RETURN msg;
END;
$$ LANGUAGE plpgsql;

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
    

CREATE OR REPLACE FUNCTION claims_aplication(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	v_amount			real;
	msg 				varchar(120);
BEGIN
	msg := 'Advance applied';
	
	SELECT sum(amount) INTO v_amount
	FROM vw_claim_details
	WHERE (claim_id = $1::int);
	
	IF(v_amount is null)THEN
		RAISE EXCEPTION 'You need to add claim details';
	END IF;
	
	UPDATE claims SET approve_status = 'Completed'
	WHERE (claim_id = CAST($1 as int)) AND (approve_status = 'Draft');

	RETURN msg;
END;
$$ LANGUAGE plpgsql;


