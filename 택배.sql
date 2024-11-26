CREATE TABLE `User` (
	`user_id`	int	NOT NULL,
	`user_phone`	int	NULL,
	`user_email`	varchar(256)	NULL,
	`user_address`	varchar(4096)	NULL,
	`user_type`	boolean	NULL,
	`user_name`	verchar	NULL,
	`user_password`	verchar	NULL
);

CREATE TABLE `Warehouse` (
	`warehouse_id`	int	NOT NULL,
	`warehouse_name`	varchar	NULL,
	`warehouse_address`	varchar	NULL,
	`company_id`	int	NOT NULL,
	`product_id`	int	NOT NULL
);

CREATE TABLE `Stock` (
	`product_id`	int	NOT NULL,
	`warehouse_id`	int	NOT NULL,
	`quantity`	int	NULL
);

CREATE TABLE `Delivery Personnel` (
	`delivery_id`	int	NOT NULL,
	`company_id`	int	NOT NULL,
	`delivery_zone`	VARCHAR(255)	NULL
);

CREATE TABLE `make_order` (
	`order_id`	int	NOT NULL,
	`order_date`	varchar(16)	NULL,
	`availability_date`	varchar(16)	NULL,
	`user_id`	int	NOT NULL,
	`product_id`	int	NOT NULL,
	`receiver_id`	int	NOT NULL
);

CREATE TABLE `Delivery Company` (
	`company_id`	int	NOT NULL,
	`company_name`	varchar	NULL,
	`company_address`	varchar	NULL,
	`company_phone`	int	NULL
);

CREATE TABLE `Inquiry` (
	`inquiry_id`	int	NOT NULL,
	`inquiry_comment`	varchar	NULL,
	`user_id`	int	NOT NULL,
	`current_state`	boolean	NOT NULL,
	`problem_state`	boolean	NULL
);

CREATE TABLE `Shipment State` (
	`current_state`	boolean	NOT NULL,
	`update_time`	VARCHAR(255)	NULL,
	`warehouse_id`	int	NOT NULL
);

CREATE TABLE `Receiver` (
	`receiver_id`	int	NOT NULL,
	`receiver_name`	varchar	NULL,
	`receiver_phone`	int	NULL,
	`receiver_address`	varchar	NULL,
	`receiver_zip_ code`	int	NULL
);

CREATE TABLE `Parcel` (
	`parcel_id`	int	NOT NULL,
	`invoice_number`	int	NULL,
	`warehouse_id`	int	NOT NULL,
	`current_state`	boolean	NOT NULL,
	`order_id`	int	NOT NULL,
	`delovery_id`	int	NOT NULL
);

CREATE TABLE `emp` (
	`employee_id`	int	NOT NULL,
	`employee_phone`	varchar	NULL,
	`user_id`	int	NOT NULL
);

CREATE TABLE `Delivery issue Management` (
	`issue_id`	int	NOT NULL,
	`issue_type`	varchar	NULL,
	`issue_date`	varchar	NULL,
	`inquiry_id`	int	NOT NULL
);

CREATE TABLE `Report` (
	`report_id`	int	NOT NULL,
	`report_date`	varrchar	NULL,
	`report_type`	varchar	NULL,
	`report_data`	varchar	NULL,
	`issue_id`	int	NOT NULL,
	`id2`	int	NOT NULL
);

CREATE TABLE `Product` (
	`product_id`	int	NOT NULL,
	`product_name`	verchar	NULL,
	`factory_id`	int	NOT NULL
);

CREATE TABLE `Factory` (
	`factory_id`	int	NOT NULL,
	`factory_name`	verchar	NULL
);

ALTER TABLE `User` ADD CONSTRAINT `PK_USER` PRIMARY KEY (
	`user_id`
);

ALTER TABLE `Warehouse` ADD CONSTRAINT `PK_WAREHOUSE` PRIMARY KEY (
	`warehouse_id`
);

ALTER TABLE `Stock` ADD CONSTRAINT `PK_STOCK` PRIMARY KEY (
	`product_id`,
	`warehouse_id`
);

ALTER TABLE `Delivery Personnel` ADD CONSTRAINT `PK_DELIVERY PERSONNEL` PRIMARY KEY (
	`delivery_id`
);

ALTER TABLE `make_order` ADD CONSTRAINT `PK_MAKE_ORDER` PRIMARY KEY (
	`order_id`
);

ALTER TABLE `Delivery Company` ADD CONSTRAINT `PK_DELIVERY COMPANY` PRIMARY KEY (
	`company_id`
);

ALTER TABLE `Inquiry` ADD CONSTRAINT `PK_INQUIRY` PRIMARY KEY (
	`inquiry_id`
);

ALTER TABLE `Shipment State` ADD CONSTRAINT `PK_SHIPMENT STATE` PRIMARY KEY (
	`current_state`
);

ALTER TABLE `Receiver` ADD CONSTRAINT `PK_RECEIVER` PRIMARY KEY (
	`receiver_id`
);

ALTER TABLE `Parcel` ADD CONSTRAINT `PK_PARCEL` PRIMARY KEY (
	`parcel_id`
);

ALTER TABLE `emp` ADD CONSTRAINT `PK_EMP` PRIMARY KEY (
	`employee_id`
);

ALTER TABLE `Delivery issue Management` ADD CONSTRAINT `PK_DELIVERY ISSUE MANAGEMENT` PRIMARY KEY (
	`issue_id`
);

ALTER TABLE `Report` ADD CONSTRAINT `PK_REPORT` PRIMARY KEY (
	`report_id`
);

ALTER TABLE `Product` ADD CONSTRAINT `PK_PRODUCT` PRIMARY KEY (
	`product_id`
);

ALTER TABLE `Factory` ADD CONSTRAINT `PK_FACTORY` PRIMARY KEY (
	`factory_id`
);

ALTER TABLE `Stock` ADD CONSTRAINT `FK_Product_TO_Stock_1` FOREIGN KEY (
	`product_id`
)
REFERENCES `Product` (
	`product_id`
);

ALTER TABLE `Stock` ADD CONSTRAINT `FK_Warehouse_TO_Stock_1` FOREIGN KEY (
	`warehouse_id`
)
REFERENCES `Warehouse` (
	`warehouse_id`
);

