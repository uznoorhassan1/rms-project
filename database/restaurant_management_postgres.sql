-- Restaurant Management System: PostgreSQL version (converted from Oracle)
-- Run in pgAdmin Query Tool on an empty database. Safe to re-run.

-- ===== Drop existing tables (safe to re-run) =====
DROP TABLE IF EXISTS BILL_SPLIT, PAYMENT, ORDER_DETAIL, ORDERS, PURCHASE_ORDER_DETAIL, PURCHASE_ORDER, RESERVATION, SHIFT_SCHEDULE, RECIPE_INGREDIENT, MENU_DISCOUNT, INVENTORY_ITEM, MENU_ITEM, EMPLOYEE, RESTAURANT_TABLE, CUSTOMER, SUPPLIER, CATEGORY, PAYMENT_METHOD, ORDER_TYPE, TABLE_SECTION, EMPLOYEE_ROLE CASCADE;

-- ===== Tables =====

CREATE TABLE EMPLOYEE_ROLE (
  Role_ID              INTEGER CONSTRAINT pk_erole PRIMARY KEY,
  RoleName             VARCHAR(30) NOT NULL,
  RoleDescription      VARCHAR(150),
  AccessLevel          INTEGER
);

CREATE TABLE TABLE_SECTION (
  Section_ID           INTEGER CONSTRAINT pk_tsec PRIMARY KEY,
  SectionName          VARCHAR(40) NOT NULL,
  FloorNumber          INTEGER,
  Description          VARCHAR(200)
);

CREATE TABLE ORDER_TYPE (
  OrderType_ID         INTEGER CONSTRAINT pk_otyp PRIMARY KEY,
  TypeName             VARCHAR(30) NOT NULL,
  DeliveryFee          NUMERIC(8,2) DEFAULT 0
);

CREATE TABLE PAYMENT_METHOD (
  PaymentMethod_ID     INTEGER CONSTRAINT pk_pmeth PRIMARY KEY,
  MethodName           VARCHAR(30) NOT NULL,
  ProcessingFeeRate    NUMERIC(5,2)
);

CREATE TABLE CATEGORY (
  Category_ID          INTEGER CONSTRAINT pk_cat PRIMARY KEY,
  CategoryName         VARCHAR(40) NOT NULL,
  DisplayOrder         INTEGER,
  IsActive             INTEGER DEFAULT 1 NOT NULL CONSTRAINT ck_cat_isactive CHECK (IsActive IN (0,1))
);

CREATE TABLE SUPPLIER (
  Supplier_ID          INTEGER CONSTRAINT pk_supp PRIMARY KEY,
  CompanyName          VARCHAR(60) NOT NULL,
  ContactPerson        VARCHAR(60),
  Phone                VARCHAR(15),
  Email                VARCHAR(60),
  City                 VARCHAR(30),
  State                VARCHAR(30),
  ZIP                  VARCHAR(10),
  Street               VARCHAR(80),
  PaymentTerms         VARCHAR(20)
);

CREATE TABLE CUSTOMER (
  Customer_ID          INTEGER CONSTRAINT pk_cust PRIMARY KEY,
  FirstName            VARCHAR(30) NOT NULL,
  LastName             VARCHAR(30) NOT NULL,
  Phone                VARCHAR(15),
  Email                VARCHAR(60) CONSTRAINT uq_cust_email UNIQUE,
  RegistrationDate     DATE,
  DOB                  DATE,
  Dietary_Preference   VARCHAR(30),
  IsVIP                INTEGER DEFAULT 0 NOT NULL CONSTRAINT ck_cust_isvip CHECK (IsVIP IN (0,1))
);

CREATE TABLE RESTAURANT_TABLE (
  Table_ID             INTEGER CONSTRAINT pk_rtab PRIMARY KEY,
  TableNumber          INTEGER NOT NULL CONSTRAINT uq_rtab_tablenumber UNIQUE,
  Capacity             INTEGER NOT NULL CONSTRAINT ck_rtab_capacity CHECK (Capacity > 0),
  Section_ID           INTEGER CONSTRAINT fk_rtab_section REFERENCES TABLE_SECTION(Section_ID),
  Status               VARCHAR(20) CONSTRAINT ck_rtab_status CHECK (Status IN ('Available','Occupied','Reserved','Cleaning')),
  SmokingAllowed       INTEGER DEFAULT 0 CONSTRAINT ck_rtab_smokingallowed CHECK (SmokingAllowed IN (0,1)),
  Shape                VARCHAR(15)
);

CREATE TABLE EMPLOYEE (
  Employee_ID          INTEGER CONSTRAINT pk_emp PRIMARY KEY,
  Role_ID              INTEGER NOT NULL CONSTRAINT fk_emp_role REFERENCES EMPLOYEE_ROLE(Role_ID),
  FirstName            VARCHAR(30) NOT NULL,
  LastName             VARCHAR(30) NOT NULL,
  Phone                VARCHAR(15),
  Email                VARCHAR(60) CONSTRAINT uq_emp_email UNIQUE,
  HireDate             DATE,
  HourlyRate           NUMERIC(8,2),
  IsActive             INTEGER DEFAULT 1 NOT NULL CONSTRAINT ck_emp_isactive CHECK (IsActive IN (0,1))
);

CREATE TABLE MENU_ITEM (
  MenuItem_ID          INTEGER CONSTRAINT pk_mitem PRIMARY KEY,
  Category_ID          INTEGER NOT NULL CONSTRAINT fk_mitem_category REFERENCES CATEGORY(Category_ID),
  Name                 VARCHAR(60) NOT NULL,
  Description          VARCHAR(200),
  UnitPrice            NUMERIC(8,2) NOT NULL,
  PreparationTime      INTEGER,
  Calories             INTEGER,
  IsAvailable          INTEGER DEFAULT 1 NOT NULL CONSTRAINT ck_mitem_isavailable CHECK (IsAvailable IN (0,1)),
  IsSpicy              INTEGER DEFAULT 0 NOT NULL CONSTRAINT ck_mitem_isspicy CHECK (IsSpicy IN (0,1))
);

CREATE TABLE INVENTORY_ITEM (
  InventoryItem_ID     INTEGER CONSTRAINT pk_inv PRIMARY KEY,
  ItemName             VARCHAR(40) NOT NULL,
  QuantityInStock      NUMERIC(8,2),
  UnitOfMeasure        VARCHAR(15),
  ReorderThreshold     NUMERIC(8,2),
  CostPerUnit          NUMERIC(8,2),
  LastRestockDate      DATE
);

CREATE TABLE MENU_DISCOUNT (
  Discount_ID          INTEGER CONSTRAINT pk_mdisc PRIMARY KEY,
  MenuItem_ID          INTEGER NOT NULL CONSTRAINT fk_mdisc_menuitem REFERENCES MENU_ITEM(MenuItem_ID),
  DiscountName         VARCHAR(40),
  Percentage           NUMERIC(5,2) CONSTRAINT ck_mdisc_percentage CHECK (Percentage BETWEEN 0 AND 100),
  StartDate            DATE,
  EndDate              DATE,
  IsActive             INTEGER DEFAULT 1 NOT NULL CONSTRAINT ck_mdisc_isactive CHECK (IsActive IN (0,1))
);

CREATE TABLE RECIPE_INGREDIENT (
  Recipe_ID            INTEGER CONSTRAINT pk_recipe PRIMARY KEY,
  MenuItem_ID          INTEGER NOT NULL CONSTRAINT fk_recipe_menuitem REFERENCES MENU_ITEM(MenuItem_ID),
  InventoryItem_ID     INTEGER NOT NULL CONSTRAINT fk_recipe_inventoryitem REFERENCES INVENTORY_ITEM(InventoryItem_ID),
  QuantityRequired     NUMERIC(8,3),
  UnitOfMeasure        VARCHAR(15)
);

CREATE TABLE SHIFT_SCHEDULE (
  Shift_ID             INTEGER CONSTRAINT pk_shift PRIMARY KEY,
  Employee_ID          INTEGER NOT NULL CONSTRAINT fk_shift_employee REFERENCES EMPLOYEE(Employee_ID),
  ShiftDate            DATE,
  StartTime            VARCHAR(5),
  EndTime              VARCHAR(5),
  ShiftType            VARCHAR(15) CONSTRAINT ck_shift_shifttype CHECK (ShiftType IN ('Morning','Evening','Full Day'))
);

CREATE TABLE RESERVATION (
  Reservation_ID       INTEGER CONSTRAINT pk_resv PRIMARY KEY,
  Customer_ID          INTEGER NOT NULL CONSTRAINT fk_resv_customer REFERENCES CUSTOMER(Customer_ID),
  Table_ID             INTEGER NOT NULL CONSTRAINT fk_resv_table REFERENCES RESTAURANT_TABLE(Table_ID),
  ReservationDate      DATE NOT NULL,
  ReservationTime      VARCHAR(5) NOT NULL,
  NumberOfPeople       INTEGER NOT NULL CONSTRAINT ck_resv_numberofpeople CHECK (NumberOfPeople > 0),
  SpecialRequests      VARCHAR(200),
  Status               VARCHAR(15) CONSTRAINT ck_resv_status CHECK (Status IN ('Pending','Confirmed','Completed','Cancelled','No-Show')),
  CreatedAt            TIMESTAMP
);

CREATE TABLE PURCHASE_ORDER (
  PurchaseOrder_ID     INTEGER CONSTRAINT pk_po PRIMARY KEY,
  Supplier_ID          INTEGER NOT NULL CONSTRAINT fk_po_supplier REFERENCES SUPPLIER(Supplier_ID),
  Employee_ID          INTEGER NOT NULL CONSTRAINT fk_po_employee REFERENCES EMPLOYEE(Employee_ID),
  OrderDate            DATE,
  ExpectedDelivery     DATE,
  TotalCost            NUMERIC(12,2),
  Status               VARCHAR(15) CONSTRAINT ck_po_status CHECK (Status IN ('Pending','In Transit','Delivered','Cancelled'))
);

CREATE TABLE PURCHASE_ORDER_DETAIL (
  PODetail_ID          INTEGER CONSTRAINT pk_pod PRIMARY KEY,
  PurchaseOrder_ID     INTEGER NOT NULL CONSTRAINT fk_pod_purchaseorder REFERENCES PURCHASE_ORDER(PurchaseOrder_ID),
  InventoryItem_ID     INTEGER NOT NULL CONSTRAINT fk_pod_inventoryitem REFERENCES INVENTORY_ITEM(InventoryItem_ID),
  QuantityOrdered      NUMERIC(8,2),
  UnitPrice            NUMERIC(8,2)
);

CREATE TABLE ORDERS (
  Order_ID             INTEGER CONSTRAINT pk_ord PRIMARY KEY,
  Table_ID             INTEGER CONSTRAINT fk_ord_table REFERENCES RESTAURANT_TABLE(Table_ID),
  Employee_ID          INTEGER CONSTRAINT fk_ord_employee REFERENCES EMPLOYEE(Employee_ID),
  Customer_ID          INTEGER CONSTRAINT fk_ord_customer REFERENCES CUSTOMER(Customer_ID),
  OrderType_ID         INTEGER NOT NULL CONSTRAINT fk_ord_ordertype REFERENCES ORDER_TYPE(OrderType_ID),
  OrderDate            DATE NOT NULL,
  OrderTime            VARCHAR(5),
  OrderStatus          VARCHAR(15) CONSTRAINT ck_ord_orderstatus CHECK (OrderStatus IN ('Pending','In Progress','Completed','Cancelled')),
  TotalAmount          NUMERIC(10,2),
  TaxAmount            NUMERIC(10,2),
  DiscountAmount       NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE ORDER_DETAIL (
  OrderDetail_ID       INTEGER CONSTRAINT pk_odet PRIMARY KEY,
  Order_ID             INTEGER NOT NULL CONSTRAINT fk_odet_order REFERENCES ORDERS(Order_ID),
  MenuItem_ID          INTEGER NOT NULL CONSTRAINT fk_odet_menuitem REFERENCES MENU_ITEM(MenuItem_ID),
  Quantity             INTEGER NOT NULL CONSTRAINT ck_odet_quantity CHECK (Quantity > 0),
  UnitPrice            NUMERIC(8,2),
  SubtotalPrice        NUMERIC(10,2),
  SpecialInstructions  VARCHAR(150),
  ItemStatus           VARCHAR(15) CONSTRAINT ck_odet_itemstatus CHECK (ItemStatus IN ('Pending','Preparing','Served','Cancelled'))
);

CREATE TABLE PAYMENT (
  Payment_ID           INTEGER CONSTRAINT pk_pay PRIMARY KEY,
  Order_ID             INTEGER NOT NULL CONSTRAINT fk_pay_order REFERENCES ORDERS(Order_ID),
  PaymentMethod_ID     INTEGER NOT NULL CONSTRAINT fk_pay_paymentmethod REFERENCES PAYMENT_METHOD(PaymentMethod_ID),
  PaymentDate          DATE,
  PaymentTime          VARCHAR(5),
  AmountPaid           NUMERIC(10,2),
  TipAmount            NUMERIC(8,2) DEFAULT 0,
  TransactionStatus    VARCHAR(15) CONSTRAINT ck_pay_transactionsta CHECK (TransactionStatus IN ('Pending','Completed','Failed','Refunded'))
);

CREATE TABLE BILL_SPLIT (
  BillSplit_ID         INTEGER CONSTRAINT pk_bsplit PRIMARY KEY,
  Order_ID             INTEGER NOT NULL CONSTRAINT fk_bsplit_order REFERENCES ORDERS(Order_ID),
  SplitNumber          INTEGER NOT NULL,
  Amount               NUMERIC(10,2),
  IsPaid               INTEGER DEFAULT 0 NOT NULL CONSTRAINT ck_bsplit_ispaid CHECK (IsPaid IN (0,1)),
  Payment_ID           INTEGER CONSTRAINT fk_bsplit_payment REFERENCES PAYMENT(Payment_ID)
);

-- ===== Data =====

-- EMPLOYEE_ROLE (8 rows)
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (1, 'Manager', 'Oversees daily restaurant operations and staff', 5);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (2, 'Head Chef', 'Leads the kitchen and designs menus', 4);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (3, 'Chef', 'Prepares dishes in the kitchen', 3);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (4, 'Waiter', 'Takes orders and serves guests', 2);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (5, 'Cashier', 'Handles billing and payments', 3);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (6, 'Host', 'Greets guests and manages reservations', 2);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (7, 'Bartender', 'Prepares beverages at the bar', 2);
INSERT INTO EMPLOYEE_ROLE (Role_ID, RoleName, RoleDescription, AccessLevel) VALUES (8, 'Kitchen Helper', 'Assists with prep and cleaning', 1);

-- TABLE_SECTION (6 rows)
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (1, 'Main Hall', 1, 'Central indoor dining area with air conditioning');
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (2, 'Patio', 1, 'Open-air seating with garden view');
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (3, 'Rooftop', 3, 'Rooftop terrace with city skyline view');
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (4, 'Private Dining', 2, 'Enclosed rooms for private events');
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (5, 'Bar Area', 1, 'Counter and high-top seating near the bar');
INSERT INTO TABLE_SECTION (Section_ID, SectionName, FloorNumber, Description) VALUES (6, 'Family Zone', 2, 'Spacious tables for families with kids');

-- ORDER_TYPE (4 rows)
INSERT INTO ORDER_TYPE (OrderType_ID, TypeName, DeliveryFee) VALUES (1, 'Dine-In', 0);
INSERT INTO ORDER_TYPE (OrderType_ID, TypeName, DeliveryFee) VALUES (2, 'Takeaway', 0);
INSERT INTO ORDER_TYPE (OrderType_ID, TypeName, DeliveryFee) VALUES (3, 'Delivery', 150);
INSERT INTO ORDER_TYPE (OrderType_ID, TypeName, DeliveryFee) VALUES (4, 'Catering', 500);

-- PAYMENT_METHOD (6 rows)
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (1, 'Cash', 0);
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (2, 'Visa Card', 2.5);
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (3, 'Mastercard', 2.5);
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (4, 'JazzCash', 1.5);
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (5, 'Easypaisa', 1.5);
INSERT INTO PAYMENT_METHOD (PaymentMethod_ID, MethodName, ProcessingFeeRate) VALUES (6, 'Bank Transfer', 1.0);

-- CATEGORY (10 rows)
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (1, 'Starters', 1, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (2, 'Soups', 2, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (3, 'Salads', 3, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (4, 'BBQ & Grill', 4, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (5, 'Main Course', 5, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (6, 'Rice & Biryani', 6, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (7, 'Breads', 7, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (8, 'Desserts', 8, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (9, 'Beverages', 9, 1);
INSERT INTO CATEGORY (Category_ID, CategoryName, DisplayOrder, IsActive) VALUES (10, 'Kids Menu', 10, 1);

-- SUPPLIER (20 rows)
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (1, 'Al-Madina Meats', 'Omar Abbasi', '0345-8812311', 'sales@almadinameats.example.com', 'Karachi', 'Sindh', '75500', 'Plot 58, Wholesale Market', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (2, 'Fresh Farms Produce', 'Naveed Hussain', '0302-9588401', 'sales@freshfarmsproduce.example.com', 'Multan', 'Punjab', '60000', 'Plot 61, Wholesale Market', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (3, 'Rawal Dairy Products', 'Noor Niazi', '0301-8492589', 'sales@rawaldairyproducts.example.com', 'Rawalpindi', 'Punjab', '46000', 'Plot 39, Sabzi Mandi Road', 'Net 15');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (4, 'Lahore Spice House', 'Rabia Cheema', '0300-7646461', 'sales@lahorespicehouse.example.com', 'Peshawar', 'KPK', '25000', 'Plot 58, Wholesale Market', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (5, 'Karachi Seafood Traders', 'Ahmed Malik', '0300-9864766', 'sales@karachiseafoodtraders.example.com', 'Sargodha', 'Punjab', '40100', 'Plot 9, Industrial Area', 'Net 15');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (6, 'Punjab Rice Mills', 'Faisal Sheikh', '0303-5059130', 'sales@punjabricemills.example.com', 'Lahore', 'Punjab', '54000', 'Plot 77, Industrial Area', 'COD');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (7, 'Green Valley Vegetables', 'Waqas Siddiqui', '0321-8390885', 'sales@greenvalleyvegetables.example.com', 'Faisalabad', 'Punjab', '38000', 'Plot 76, Sabzi Mandi Road', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (8, 'Metro Wholesale Mart', 'Fatima Javed', '0312-9384802', 'sales@metrowholesalemart.example.com', 'Islamabad', 'ICT', '44000', 'Plot 1, Industrial Area', 'COD');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (9, 'Golden Oil and Ghee', 'Areeba Gill', '0312-7824614', 'sales@goldenoilandghee.example.com', 'Karachi', 'Sindh', '75500', 'Plot 71, Industrial Area', 'Net 45');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (10, 'Sweet Treats Bakers Supply', 'Amna Cheema', '0321-4853154', 'sales@sweettreatsbakerssupply.example.com', 'Multan', 'Punjab', '60000', 'Plot 66, Main GT Road', 'Net 15');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (11, 'Hilltop Beverages', 'Hamza Khan', '0301-2810713', 'sales@hilltopbeverages.example.com', 'Rawalpindi', 'Punjab', '46000', 'Plot 52, Industrial Area', 'Net 45');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (12, 'Capital Poultry Farms', 'Kashif Chaudhry', '0333-2121162', 'sales@capitalpoultryfarms.example.com', 'Peshawar', 'KPK', '25000', 'Plot 3, Industrial Area', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (13, 'Indus Flour Mills', 'Junaid Raza', '0303-1877827', 'sales@indusflourmills.example.com', 'Sargodha', 'Punjab', '40100', 'Plot 61, Trade Center', 'COD');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (14, 'Khyber Dry Fruits', 'Hira Mirza', '0333-2225380', 'sales@khyberdryfruits.example.com', 'Lahore', 'Punjab', '54000', 'Plot 73, Sabzi Mandi Road', 'Net 45');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (15, 'Crescent Packaging', 'Mahnoor Gill', '0321-2462037', 'sales@crescentpackaging.example.com', 'Faisalabad', 'Punjab', '38000', 'Plot 40, Main GT Road', 'Net 15');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (16, 'CleanPro Supplies', 'Hina Baig', '0333-2979571', 'sales@cleanprosupplies.example.com', 'Islamabad', 'ICT', '44000', 'Plot 18, Sabzi Mandi Road', 'Net 15');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (17, 'Murree Mineral Water', 'Usman Anwar', '0300-2004844', 'sales@murreemineralwater.example.com', 'Karachi', 'Sindh', '75500', 'Plot 60, Trade Center', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (18, 'Sargodha Citrus Co', 'Talha Butt', '0303-8506543', 'sales@sargodhacitrusco.example.com', 'Multan', 'Punjab', '60000', 'Plot 66, Sabzi Mandi Road', 'Net 30');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (19, 'Islamabad Bakery Supply', 'Shahid Qureshi', '0333-7438286', 'sales@islamabadbakerysupply.example.com', 'Rawalpindi', 'Punjab', '46000', 'Plot 15, Trade Center', 'COD');
INSERT INTO SUPPLIER (Supplier_ID, CompanyName, ContactPerson, Phone, Email, City, State, ZIP, Street, PaymentTerms) VALUES (20, 'Northern Tea Traders', 'Zainab Mirza', '0303-1007900', 'sales@northernteatraders.example.com', 'Peshawar', 'KPK', '25000', 'Plot 35, Wholesale Market', 'Net 45');

-- CUSTOMER (80 rows)
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (1, 'Faisal', 'Chaudhry', '0300-4535130', 'faisal.chaudhry1@example.com', TO_DATE('2025-01-18','YYYY-MM-DD'), TO_DATE('1995-05-16','YYYY-MM-DD'), 'Nut Allergy', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (2, 'Waqas', 'Raza', '0301-1706451', 'waqas.raza2@example.com', TO_DATE('2024-10-26','YYYY-MM-DD'), TO_DATE('1979-02-17','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (3, 'Fatima', 'Mirza', '0312-1160645', 'fatima.mirza3@example.com', TO_DATE('2025-11-04','YYYY-MM-DD'), TO_DATE('1986-08-01','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (4, 'Areeba', 'Awan', '0301-2246228', 'areeba.awan4@example.com', TO_DATE('2024-07-03','YYYY-MM-DD'), TO_DATE('1978-09-22','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (5, 'Amna', 'Baig', '0303-1260199', 'amna.baig5@example.com', TO_DATE('2026-01-25','YYYY-MM-DD'), TO_DATE('1993-05-06','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (6, 'Hamza', 'Anwar', '0345-3134415', 'hamza.anwar6@example.com', TO_DATE('2026-09-17','YYYY-MM-DD'), TO_DATE('1972-03-05','YYYY-MM-DD'), 'Nut Allergy', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (7, 'Kashif', 'Butt', '0333-4067340', 'kashif.butt7@example.com', TO_DATE('2024-11-11','YYYY-MM-DD'), TO_DATE('1987-11-19','YYYY-MM-DD'), 'Lactose Intolerant', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (8, 'Junaid', 'Qureshi', '0303-5185891', 'junaid.qureshi8@example.com', TO_DATE('2025-01-23','YYYY-MM-DD'), TO_DATE('1974-03-20','YYYY-MM-DD'), 'Vegan', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (9, 'Hira', 'Abbasi', '0303-7513081', 'hira.abbasi9@example.com', TO_DATE('2026-09-15','YYYY-MM-DD'), TO_DATE('1967-01-16','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (10, 'Mahnoor', 'Awan', '0300-2742140', 'mahnoor.awan10@example.com', TO_DATE('2024-08-11','YYYY-MM-DD'), TO_DATE('1963-06-22','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (11, 'Hina', 'Rana', '0312-4999808', 'hina.rana11@example.com', TO_DATE('2026-03-13','YYYY-MM-DD'), TO_DATE('1983-01-20','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (12, 'Usman', 'Farooq', '0345-5923028', 'usman.farooq12@example.com', TO_DATE('2024-12-25','YYYY-MM-DD'), TO_DATE('1966-03-03','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (13, 'Talha', 'Malik', '0303-9041318', 'talha.malik13@example.com', TO_DATE('2024-05-31','YYYY-MM-DD'), TO_DATE('1985-02-20','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (14, 'Shahid', 'Sheikh', '0303-1278078', 'shahid.sheikh14@example.com', TO_DATE('2024-05-21','YYYY-MM-DD'), TO_DATE('1984-02-24','YYYY-MM-DD'), 'None', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (15, 'Zainab', 'Abbasi', '0345-5178601', 'zainab.abbasi15@example.com', TO_DATE('2024-05-03','YYYY-MM-DD'), TO_DATE('1964-03-06','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (16, 'Anam', 'Hussain', '0312-7187191', 'anam.hussain16@example.com', TO_DATE('2024-09-26','YYYY-MM-DD'), TO_DATE('1968-04-08','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (17, 'Nimra', 'Niazi', '0302-8555547', 'nimra.niazi17@example.com', TO_DATE('2025-11-08','YYYY-MM-DD'), TO_DATE('2006-10-28','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (18, 'Zain', 'Cheema', '0302-1588553', 'zain.cheema18@example.com', TO_DATE('2024-02-06','YYYY-MM-DD'), TO_DATE('2002-08-06','YYYY-MM-DD'), 'Lactose Intolerant', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (19, 'Danish', 'Khan', '0321-6231214', 'danish.khan19@example.com', TO_DATE('2024-03-09','YYYY-MM-DD'), TO_DATE('1961-11-27','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (20, 'Ayesha', 'Sheikh', '0301-9090572', 'ayesha.sheikh20@example.com', TO_DATE('2024-05-17','YYYY-MM-DD'), TO_DATE('1987-11-27','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (21, 'Iqra', 'Siddiqui', '0302-2215208', 'iqra.siddiqui21@example.com', TO_DATE('2024-06-03','YYYY-MM-DD'), TO_DATE('2000-08-24','YYYY-MM-DD'), 'Vegetarian', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (22, 'Kinza', 'Javed', '0321-1745997', 'kinza.javed22@example.com', TO_DATE('2024-09-22','YYYY-MM-DD'), TO_DATE('1990-08-25','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (23, 'Ali', 'Gill', '0301-8940294', 'ali.gill23@example.com', TO_DATE('2024-06-08','YYYY-MM-DD'), TO_DATE('1997-06-04','YYYY-MM-DD'), 'Gluten-Free', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (24, 'Imran', 'Baig', '0300-9387360', 'imran.baig24@example.com', TO_DATE('2024-01-30','YYYY-MM-DD'), TO_DATE('1994-04-20','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (25, 'Adnan', 'Khan', '0300-2212138', 'adnan.khan25@example.com', TO_DATE('2024-06-13','YYYY-MM-DD'), TO_DATE('1968-02-18','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (26, 'Sana', 'Chaudhry', '0301-5315154', 'sana.chaudhry26@example.com', TO_DATE('2026-05-02','YYYY-MM-DD'), TO_DATE('1989-08-14','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (27, 'Laiba', 'Raza', '0345-8390741', 'laiba.raza27@example.com', TO_DATE('2026-08-05','YYYY-MM-DD'), TO_DATE('1967-07-08','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (28, 'Saba', 'Mirza', '0300-6204879', 'saba.mirza28@example.com', TO_DATE('2024-06-28','YYYY-MM-DD'), TO_DATE('2003-02-23','YYYY-MM-DD'), 'None', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (29, 'Bilal', 'Awan', '0303-2893894', 'bilal.awan29@example.com', TO_DATE('2026-10-15','YYYY-MM-DD'), TO_DATE('2003-08-17','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (30, 'Saad', 'Baig', '0300-7173199', 'saad.baig30@example.com', TO_DATE('2025-09-08','YYYY-MM-DD'), TO_DATE('1972-11-06','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (31, 'Rehan', 'Anwar', '0303-9697218', 'rehan.anwar31@example.com', TO_DATE('2024-12-13','YYYY-MM-DD'), TO_DATE('1990-09-23','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (32, 'Maryam', 'Butt', '0345-9360271', 'maryam.butt32@example.com', TO_DATE('2025-05-09','YYYY-MM-DD'), TO_DATE('1989-05-01','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (33, 'Sidra', 'Qureshi', '0312-4330374', 'sidra.qureshi33@example.com', TO_DATE('2026-06-01','YYYY-MM-DD'), TO_DATE('1977-12-20','YYYY-MM-DD'), 'Lactose Intolerant', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (34, 'Mehwish', 'Abbasi', '0303-7449475', 'mehwish.abbasi34@example.com', TO_DATE('2025-03-25','YYYY-MM-DD'), TO_DATE('1988-05-23','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (35, 'Hassan', 'Awan', '0302-3257420', 'hassan.awan35@example.com', TO_DATE('2026-10-13','YYYY-MM-DD'), TO_DATE('1991-06-20','YYYY-MM-DD'), 'Nut Allergy', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (36, 'Omar', 'Rana', '0300-2076074', 'omar.rana36@example.com', TO_DATE('2025-07-20','YYYY-MM-DD'), TO_DATE('1975-03-05','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (37, 'Naveed', 'Farooq', '0345-8907969', 'naveed.farooq37@example.com', TO_DATE('2025-07-17','YYYY-MM-DD'), TO_DATE('1979-03-16','YYYY-MM-DD'), 'Nut Allergy', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (38, 'Noor', 'Malik', '0333-7418092', 'noor.malik38@example.com', TO_DATE('2026-10-08','YYYY-MM-DD'), TO_DATE('1988-04-17','YYYY-MM-DD'), 'Vegan', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (39, 'Rabia', 'Sheikh', '0345-6374517', 'rabia.sheikh39@example.com', TO_DATE('2024-06-01','YYYY-MM-DD'), TO_DATE('1962-10-28','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (40, 'Ahmed', 'Abbasi', '0300-5715577', 'ahmed.abbasi40@example.com', TO_DATE('2025-12-26','YYYY-MM-DD'), TO_DATE('1987-09-22','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (41, 'Faisal', 'Hussain', '0300-3279707', 'faisal.hussain41@example.com', TO_DATE('2026-04-09','YYYY-MM-DD'), TO_DATE('2000-10-20','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (42, 'Waqas', 'Niazi', '0300-5469660', 'waqas.niazi42@example.com', TO_DATE('2025-05-01','YYYY-MM-DD'), TO_DATE('1972-08-21','YYYY-MM-DD'), 'Gluten-Free', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (43, 'Fatima', 'Cheema', '0300-2934494', 'fatima.cheema43@example.com', TO_DATE('2026-07-03','YYYY-MM-DD'), TO_DATE('1969-10-12','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (44, 'Areeba', 'Khan', '0321-2308092', 'areeba.khan44@example.com', TO_DATE('2025-02-09','YYYY-MM-DD'), TO_DATE('1977-11-19','YYYY-MM-DD'), 'Nut Allergy', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (45, 'Amna', 'Sheikh', '0345-5295675', 'amna.sheikh45@example.com', TO_DATE('2024-12-31','YYYY-MM-DD'), TO_DATE('1960-12-18','YYYY-MM-DD'), 'Gluten-Free', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (46, 'Hamza', 'Siddiqui', '0345-9973269', 'hamza.siddiqui46@example.com', TO_DATE('2024-03-15','YYYY-MM-DD'), TO_DATE('1976-01-25','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (47, 'Kashif', 'Javed', '0312-6800546', 'kashif.javed47@example.com', TO_DATE('2026-10-21','YYYY-MM-DD'), TO_DATE('1974-04-13','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (48, 'Junaid', 'Gill', '0303-2463135', 'junaid.gill48@example.com', TO_DATE('2026-04-20','YYYY-MM-DD'), TO_DATE('1994-10-22','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (49, 'Hira', 'Baig', '0345-8609074', 'hira.baig49@example.com', TO_DATE('2025-02-07','YYYY-MM-DD'), TO_DATE('1960-08-08','YYYY-MM-DD'), 'None', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (50, 'Mahnoor', 'Khan', '0321-8779724', 'mahnoor.khan50@example.com', TO_DATE('2025-10-30','YYYY-MM-DD'), TO_DATE('1978-05-19','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (51, 'Hina', 'Chaudhry', '0301-4578522', 'hina.chaudhry51@example.com', TO_DATE('2025-05-11','YYYY-MM-DD'), TO_DATE('1995-01-03','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (52, 'Usman', 'Raza', '0312-6375331', 'usman.raza52@example.com', TO_DATE('2025-06-20','YYYY-MM-DD'), TO_DATE('1961-05-27','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (53, 'Talha', 'Mirza', '0301-1623019', 'talha.mirza53@example.com', TO_DATE('2026-06-21','YYYY-MM-DD'), TO_DATE('1990-09-08','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (54, 'Shahid', 'Awan', '0333-5618042', 'shahid.awan54@example.com', TO_DATE('2026-09-25','YYYY-MM-DD'), TO_DATE('1962-07-19','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (55, 'Zainab', 'Baig', '0301-8196323', 'zainab.baig55@example.com', TO_DATE('2024-03-12','YYYY-MM-DD'), TO_DATE('1975-07-06','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (56, 'Anam', 'Anwar', '0321-3357202', 'anam.anwar56@example.com', TO_DATE('2026-08-21','YYYY-MM-DD'), TO_DATE('1973-05-03','YYYY-MM-DD'), 'Vegetarian', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (57, 'Nimra', 'Butt', '0345-9264142', 'nimra.butt57@example.com', TO_DATE('2024-06-25','YYYY-MM-DD'), TO_DATE('1979-11-12','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (58, 'Zain', 'Qureshi', '0312-3757340', 'zain.qureshi58@example.com', TO_DATE('2025-06-09','YYYY-MM-DD'), TO_DATE('1987-12-18','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (59, 'Danish', 'Abbasi', '0333-4493680', 'danish.abbasi59@example.com', TO_DATE('2025-09-15','YYYY-MM-DD'), TO_DATE('1972-08-30','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (60, 'Ayesha', 'Awan', '0312-9349141', 'ayesha.awan60@example.com', TO_DATE('2025-02-15','YYYY-MM-DD'), TO_DATE('1996-11-17','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (61, 'Iqra', 'Rana', '0301-9441860', 'iqra.rana61@example.com', TO_DATE('2024-01-11','YYYY-MM-DD'), TO_DATE('1993-10-28','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (62, 'Kinza', 'Farooq', '0300-9657341', 'kinza.farooq62@example.com', TO_DATE('2026-03-31','YYYY-MM-DD'), TO_DATE('1970-12-09','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (63, 'Ali', 'Malik', '0301-3797956', 'ali.malik63@example.com', TO_DATE('2024-05-14','YYYY-MM-DD'), TO_DATE('2001-03-04','YYYY-MM-DD'), 'None', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (64, 'Imran', 'Sheikh', '0333-5516657', 'imran.sheikh64@example.com', TO_DATE('2025-05-19','YYYY-MM-DD'), TO_DATE('2002-06-13','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (65, 'Adnan', 'Abbasi', '0302-6698898', 'adnan.abbasi65@example.com', TO_DATE('2026-06-07','YYYY-MM-DD'), TO_DATE('2002-10-02','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (66, 'Sana', 'Hussain', '0321-2822234', 'sana.hussain66@example.com', TO_DATE('2025-01-27','YYYY-MM-DD'), TO_DATE('1997-08-21','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (67, 'Laiba', 'Niazi', '0300-5365813', 'laiba.niazi67@example.com', TO_DATE('2024-09-22','YYYY-MM-DD'), TO_DATE('1962-01-16','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (68, 'Saba', 'Cheema', '0303-3609344', 'saba.cheema68@example.com', TO_DATE('2025-04-10','YYYY-MM-DD'), TO_DATE('1961-01-22','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (69, 'Bilal', 'Khan', '0312-6403643', 'bilal.khan69@example.com', TO_DATE('2025-12-28','YYYY-MM-DD'), TO_DATE('1981-12-06','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (70, 'Saad', 'Sheikh', '0345-2759686', 'saad.sheikh70@example.com', TO_DATE('2026-10-20','YYYY-MM-DD'), TO_DATE('1971-01-06','YYYY-MM-DD'), 'Nut Allergy', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (71, 'Rehan', 'Siddiqui', '0312-4317339', 'rehan.siddiqui71@example.com', TO_DATE('2026-06-13','YYYY-MM-DD'), TO_DATE('1962-01-31','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (72, 'Maryam', 'Javed', '0333-9880980', 'maryam.javed72@example.com', TO_DATE('2024-11-23','YYYY-MM-DD'), TO_DATE('1978-04-29','YYYY-MM-DD'), 'Nut Allergy', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (73, 'Sidra', 'Gill', '0303-9885532', 'sidra.gill73@example.com', TO_DATE('2025-03-18','YYYY-MM-DD'), TO_DATE('1972-03-29','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (74, 'Mehwish', 'Baig', '0321-4038940', 'mehwish.baig74@example.com', TO_DATE('2025-10-08','YYYY-MM-DD'), TO_DATE('1988-04-04','YYYY-MM-DD'), 'Lactose Intolerant', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (75, 'Hassan', 'Khan', '0303-4659854', 'hassan.khan75@example.com', TO_DATE('2025-02-02','YYYY-MM-DD'), TO_DATE('1968-09-08','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (76, 'Omar', 'Chaudhry', '0303-3223678', 'omar.chaudhry76@example.com', TO_DATE('2024-06-29','YYYY-MM-DD'), TO_DATE('1983-04-13','YYYY-MM-DD'), 'None', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (77, 'Naveed', 'Raza', '0301-8294687', 'naveed.raza77@example.com', TO_DATE('2026-05-13','YYYY-MM-DD'), TO_DATE('1971-04-21','YYYY-MM-DD'), 'None', 1);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (78, 'Noor', 'Mirza', '0333-1297941', 'noor.mirza78@example.com', TO_DATE('2024-07-15','YYYY-MM-DD'), TO_DATE('1978-01-10','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (79, 'Rabia', 'Awan', '0321-7062000', 'rabia.awan79@example.com', TO_DATE('2024-08-24','YYYY-MM-DD'), TO_DATE('2005-05-14','YYYY-MM-DD'), 'Vegetarian', 0);
INSERT INTO CUSTOMER (Customer_ID, FirstName, LastName, Phone, Email, RegistrationDate, DOB, Dietary_Preference, IsVIP) VALUES (80, 'Ahmed', 'Baig', '0321-9435339', 'ahmed.baig80@example.com', TO_DATE('2025-01-22','YYYY-MM-DD'), TO_DATE('1966-04-30','YYYY-MM-DD'), 'None', 0);

-- RESTAURANT_TABLE (60 rows)
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (1, 1, 2, 1, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (2, 2, 6, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (3, 3, 2, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (4, 4, 4, 1, 'Reserved', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (5, 5, 2, 1, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (6, 6, 6, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (7, 7, 4, 1, 'Available', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (8, 8, 4, 1, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (9, 9, 4, 1, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (10, 10, 2, 1, 'Occupied', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (11, 11, 6, 1, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (12, 12, 4, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (13, 13, 4, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (14, 14, 4, 1, 'Reserved', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (15, 15, 6, 1, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (16, 16, 4, 1, 'Occupied', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (17, 17, 4, 1, 'Reserved', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (18, 18, 4, 1, 'Occupied', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (19, 19, 4, 1, 'Reserved', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (20, 20, 4, 1, 'Occupied', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (21, 21, 6, 2, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (22, 22, 4, 2, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (23, 23, 2, 2, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (24, 24, 4, 2, 'Available', 1, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (25, 25, 4, 2, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (26, 26, 4, 2, 'Occupied', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (27, 27, 2, 2, 'Available', 1, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (28, 28, 4, 2, 'Available', 1, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (29, 29, 6, 2, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (30, 30, 4, 2, 'Available', 1, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (31, 31, 6, 3, 'Occupied', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (32, 32, 6, 3, 'Available', 1, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (33, 33, 4, 3, 'Reserved', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (34, 34, 2, 3, 'Reserved', 1, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (35, 35, 2, 3, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (36, 36, 6, 3, 'Available', 1, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (37, 37, 4, 3, 'Available', 1, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (38, 38, 6, 3, 'Occupied', 1, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (39, 39, 8, 4, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (40, 40, 10, 4, 'Occupied', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (41, 41, 8, 4, 'Reserved', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (42, 42, 8, 4, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (43, 43, 8, 4, 'Occupied', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (44, 44, 10, 4, 'Occupied', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (45, 45, 2, 5, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (46, 46, 4, 5, 'Reserved', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (47, 47, 2, 5, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (48, 48, 2, 5, 'Available', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (49, 49, 2, 5, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (50, 50, 2, 5, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (51, 51, 6, 6, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (52, 52, 6, 6, 'Available', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (53, 53, 8, 6, 'Available', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (54, 54, 6, 6, 'Occupied', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (55, 55, 4, 6, 'Cleaning', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (56, 56, 4, 6, 'Available', 0, 'Round');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (57, 57, 8, 6, 'Reserved', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (58, 58, 8, 6, 'Occupied', 0, 'Square');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (59, 59, 6, 6, 'Available', 0, 'Rectangle');
INSERT INTO RESTAURANT_TABLE (Table_ID, TableNumber, Capacity, Section_ID, Status, SmokingAllowed, Shape) VALUES (60, 60, 8, 6, 'Available', 0, 'Round');

-- EMPLOYEE (50 rows)
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (1, 1, 'Junaid', 'Awan', '0303-9424663', 'junaid.awan.emp1@example.com', TO_DATE('2026-04-28','YYYY-MM-DD'), 1500, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (2, 1, 'Hira', 'Rana', '0300-2019834', 'hira.rana.emp2@example.com', TO_DATE('2019-02-08','YYYY-MM-DD'), 1510, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (3, 1, 'Mahnoor', 'Farooq', '0312-8133554', 'mahnoor.farooq.emp3@example.com', TO_DATE('2019-04-21','YYYY-MM-DD'), 1560, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (4, 2, 'Hina', 'Malik', '0300-2719154', 'hina.malik.emp4@example.com', TO_DATE('2021-06-30','YYYY-MM-DD'), 1250, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (5, 2, 'Usman', 'Qureshi', '0312-2216227', 'usman.qureshi.emp5@example.com', TO_DATE('2019-12-21','YYYY-MM-DD'), 1270, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (6, 3, 'Talha', 'Abbasi', '0302-4938520', 'talha.abbasi.emp6@example.com', TO_DATE('2026-01-29','YYYY-MM-DD'), 820, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (7, 3, 'Shahid', 'Hussain', '0345-9028829', 'shahid.hussain.emp7@example.com', TO_DATE('2022-12-21','YYYY-MM-DD'), 800, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (8, 3, 'Zainab', 'Niazi', '0321-6766337', 'zainab.niazi.emp8@example.com', TO_DATE('2024-07-18','YYYY-MM-DD'), 880, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (9, 3, 'Anam', 'Cheema', '0302-2247329', 'anam.cheema.emp9@example.com', TO_DATE('2020-05-05','YYYY-MM-DD'), 840, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (10, 3, 'Nimra', 'Malik', '0303-8454765', 'nimra.malik.emp10@example.com', TO_DATE('2023-10-05','YYYY-MM-DD'), 880, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (11, 3, 'Zain', 'Sheikh', '0312-7545221', 'zain.sheikh.emp11@example.com', TO_DATE('2020-09-09','YYYY-MM-DD'), 820, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (12, 3, 'Danish', 'Siddiqui', '0302-6459148', 'danish.siddiqui.emp12@example.com', TO_DATE('2022-04-06','YYYY-MM-DD'), 850, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (13, 3, 'Ayesha', 'Javed', '0302-8174819', 'ayesha.javed.emp13@example.com', TO_DATE('2026-05-01','YYYY-MM-DD'), 820, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (14, 4, 'Iqra', 'Gill', '0301-8751346', 'iqra.gill.emp14@example.com', TO_DATE('2022-08-20','YYYY-MM-DD'), 430, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (15, 4, 'Kinza', 'Cheema', '0301-8247563', 'kinza.cheema.emp15@example.com', TO_DATE('2025-04-30','YYYY-MM-DD'), 510, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (16, 4, 'Ali', 'Khan', '0345-8776446', 'ali.khan.emp16@example.com', TO_DATE('2022-05-09','YYYY-MM-DD'), 550, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (17, 4, 'Imran', 'Chaudhry', '0300-2276398', 'imran.chaudhry.emp17@example.com', TO_DATE('2022-06-24','YYYY-MM-DD'), 450, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (18, 4, 'Adnan', 'Raza', '0301-6097006', 'adnan.raza.emp18@example.com', TO_DATE('2024-07-19','YYYY-MM-DD'), 530, 0);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (19, 4, 'Sana', 'Mirza', '0321-5746529', 'sana.mirza.emp19@example.com', TO_DATE('2020-08-08','YYYY-MM-DD'), 450, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (20, 4, 'Laiba', 'Gill', '0321-6487255', 'laiba.gill.emp20@example.com', TO_DATE('2023-02-09','YYYY-MM-DD'), 430, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (21, 4, 'Saba', 'Baig', '0321-8398428', 'saba.baig.emp21@example.com', TO_DATE('2025-05-20','YYYY-MM-DD'), 510, 0);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (22, 4, 'Bilal', 'Anwar', '0312-8348298', 'bilal.anwar.emp22@example.com', TO_DATE('2024-12-11','YYYY-MM-DD'), 540, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (23, 4, 'Saad', 'Butt', '0312-8688593', 'saad.butt.emp23@example.com', TO_DATE('2022-07-24','YYYY-MM-DD'), 450, 0);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (24, 4, 'Rehan', 'Qureshi', '0333-9659828', 'rehan.qureshi.emp24@example.com', TO_DATE('2021-10-14','YYYY-MM-DD'), 430, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (25, 4, 'Maryam', 'Mirza', '0321-7133150', 'maryam.mirza.emp25@example.com', TO_DATE('2019-04-09','YYYY-MM-DD'), 470, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (26, 4, 'Sidra', 'Awan', '0333-7502511', 'sidra.awan.emp26@example.com', TO_DATE('2021-03-09','YYYY-MM-DD'), 530, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (27, 4, 'Mehwish', 'Rana', '0321-7547240', 'mehwish.rana.emp27@example.com', TO_DATE('2025-01-23','YYYY-MM-DD'), 440, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (28, 4, 'Hassan', 'Farooq', '0302-3962725', 'hassan.farooq.emp28@example.com', TO_DATE('2020-01-03','YYYY-MM-DD'), 540, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (29, 4, 'Omar', 'Malik', '0345-5722030', 'omar.malik.emp29@example.com', TO_DATE('2019-04-02','YYYY-MM-DD'), 450, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (30, 5, 'Naveed', 'Qureshi', '0300-3662279', 'naveed.qureshi.emp30@example.com', TO_DATE('2025-05-13','YYYY-MM-DD'), 560, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (31, 5, 'Noor', 'Abbasi', '0300-8092484', 'noor.abbasi.emp31@example.com', TO_DATE('2019-09-20','YYYY-MM-DD'), 610, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (32, 5, 'Rabia', 'Hussain', '0312-2410060', 'rabia.hussain.emp32@example.com', TO_DATE('2022-10-02','YYYY-MM-DD'), 530, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (33, 5, 'Ahmed', 'Niazi', '0312-2768411', 'ahmed.niazi.emp33@example.com', TO_DATE('2022-07-09','YYYY-MM-DD'), 530, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (34, 5, 'Faisal', 'Cheema', '0300-3413871', 'faisal.cheema.emp34@example.com', TO_DATE('2020-02-04','YYYY-MM-DD'), 630, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (35, 6, 'Waqas', 'Malik', '0333-5117971', 'waqas.malik.emp35@example.com', TO_DATE('2021-06-21','YYYY-MM-DD'), 540, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (36, 6, 'Fatima', 'Sheikh', '0321-8701918', 'fatima.sheikh.emp36@example.com', TO_DATE('2023-06-04','YYYY-MM-DD'), 520, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (37, 6, 'Areeba', 'Siddiqui', '0321-6586249', 'areeba.siddiqui.emp37@example.com', TO_DATE('2026-07-17','YYYY-MM-DD'), 490, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (38, 6, 'Amna', 'Javed', '0345-9187971', 'amna.javed.emp38@example.com', TO_DATE('2025-01-09','YYYY-MM-DD'), 590, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (39, 7, 'Hamza', 'Gill', '0301-1775789', 'hamza.gill.emp39@example.com', TO_DATE('2023-08-09','YYYY-MM-DD'), 640, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (40, 7, 'Kashif', 'Cheema', '0321-1064898', 'kashif.cheema.emp40@example.com', TO_DATE('2023-03-29','YYYY-MM-DD'), 650, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (41, 7, 'Junaid', 'Khan', '0301-8795681', 'junaid.khan.emp41@example.com', TO_DATE('2025-01-26','YYYY-MM-DD'), 620, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (42, 7, 'Hira', 'Chaudhry', '0300-9788847', 'hira.chaudhry.emp42@example.com', TO_DATE('2023-01-22','YYYY-MM-DD'), 630, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (43, 8, 'Mahnoor', 'Raza', '0300-2844269', 'mahnoor.raza.emp43@example.com', TO_DATE('2023-09-23','YYYY-MM-DD'), 380, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (44, 8, 'Hina', 'Mirza', '0302-5122503', 'hina.mirza.emp44@example.com', TO_DATE('2020-10-26','YYYY-MM-DD'), 420, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (45, 8, 'Usman', 'Gill', '0333-3812791', 'usman.gill.emp45@example.com', TO_DATE('2022-08-07','YYYY-MM-DD'), 350, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (46, 8, 'Talha', 'Baig', '0333-8129396', 'talha.baig.emp46@example.com', TO_DATE('2024-12-07','YYYY-MM-DD'), 360, 0);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (47, 8, 'Shahid', 'Anwar', '0312-1993328', 'shahid.anwar.emp47@example.com', TO_DATE('2024-04-15','YYYY-MM-DD'), 360, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (48, 8, 'Zainab', 'Butt', '0301-6091874', 'zainab.butt.emp48@example.com', TO_DATE('2026-04-08','YYYY-MM-DD'), 340, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (49, 8, 'Anam', 'Qureshi', '0302-2045967', 'anam.qureshi.emp49@example.com', TO_DATE('2024-02-23','YYYY-MM-DD'), 320, 1);
INSERT INTO EMPLOYEE (Employee_ID, Role_ID, FirstName, LastName, Phone, Email, HireDate, HourlyRate, IsActive) VALUES (50, 8, 'Nimra', 'Mirza', '0345-1610265', 'nimra.mirza.emp50@example.com', TO_DATE('2022-07-04','YYYY-MM-DD'), 330, 1);

-- MENU_ITEM (60 rows)
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (1, 1, 'Chicken Samosa', 'Crispy appetizer served with house chutney', 350, 10, 260, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (2, 1, 'Vegetable Spring Rolls', 'Crispy appetizer served with house chutney', 420, 12, 240, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (3, 1, 'Crispy Chicken Wings', 'Crispy appetizer served with house chutney', 690, 15, 430, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (4, 1, 'Dahi Bhallay', 'Crispy appetizer served with house chutney', 380, 5, 210, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (5, 1, 'Fish Fingers', 'Crispy appetizer served with house chutney', 790, 14, 380, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (6, 1, 'Garlic Mushrooms', 'Crispy appetizer served with house chutney', 550, 12, 190, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (7, 1, 'Chapli Kabab Platter', 'Crispy appetizer served with house chutney', 650, 15, 520, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (8, 1, 'Cheese Fries', 'Crispy appetizer served with house chutney', 450, 10, 480, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (9, 2, 'Chicken Corn Soup', 'Warm soup made from slow-simmered stock', 380, 8, 150, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (10, 2, 'Hot & Sour Soup', 'Warm soup made from slow-simmered stock', 400, 8, 130, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (11, 2, 'Tomato Basil Soup', 'Warm soup made from slow-simmered stock', 350, 7, 120, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (12, 2, 'Daal Shorba', 'Warm soup made from slow-simmered stock', 320, 8, 160, 0, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (13, 3, 'Caesar Salad', 'Fresh salad with seasonal vegetables', 650, 8, 310, 0, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (14, 3, 'Greek Salad', 'Fresh salad with seasonal vegetables', 600, 7, 250, 0, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (15, 3, 'Kachumber Salad', 'Fresh salad with seasonal vegetables', 250, 5, 70, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (16, 3, 'Russian Salad', 'Fresh salad with seasonal vegetables', 450, 6, 290, 0, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (17, 4, 'Chicken Tikka (2 pcs)', 'Charcoal-grilled and marinated in house spices', 620, 20, 380, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (18, 4, 'Seekh Kabab (4 pcs)', 'Charcoal-grilled and marinated in house spices', 750, 20, 450, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (19, 4, 'Beef Bihari Boti', 'Charcoal-grilled and marinated in house spices', 980, 22, 520, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (20, 4, 'Chicken Malai Boti', 'Charcoal-grilled and marinated in house spices', 850, 20, 470, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (21, 4, 'Reshmi Kabab', 'Charcoal-grilled and marinated in house spices', 780, 20, 430, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (22, 4, 'Mutton Chops', 'Charcoal-grilled and marinated in house spices', 1650, 25, 690, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (23, 4, 'Grilled Fish Fillet', 'Charcoal-grilled and marinated in house spices', 1250, 22, 410, 0, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (24, 4, 'Chicken Afghani Boti', 'Charcoal-grilled and marinated in house spices', 890, 20, 460, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (25, 5, 'Chicken Karahi (Half)', 'Signature curry cooked in traditional style', 1450, 25, 680, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (26, 5, 'Mutton Karahi (Half)', 'Signature curry cooked in traditional style', 2250, 35, 820, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (27, 5, 'Butter Chicken', 'Signature curry cooked in traditional style', 1350, 25, 720, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (28, 5, 'Beef Nihari', 'Signature curry cooked in traditional style', 1250, 30, 760, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (29, 5, 'Chicken Handi', 'Signature curry cooked in traditional style', 1380, 25, 650, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (30, 5, 'Palak Paneer', 'Signature curry cooked in traditional style', 850, 18, 420, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (31, 5, 'Daal Makhni', 'Signature curry cooked in traditional style', 650, 15, 350, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (32, 5, 'Chicken Jalfrezi', 'Signature curry cooked in traditional style', 1200, 22, 590, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (33, 5, 'Mutton Korma', 'Signature curry cooked in traditional style', 1950, 35, 800, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (34, 5, 'Haleem', 'Signature curry cooked in traditional style', 700, 10, 560, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (35, 6, 'Chicken Biryani', 'Fragrant rice dish cooked with whole spices', 650, 15, 720, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (36, 6, 'Beef Pulao', 'Fragrant rice dish cooked with whole spices', 700, 20, 680, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (37, 6, 'Vegetable Biryani', 'Fragrant rice dish cooked with whole spices', 520, 15, 540, 1, 1);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (38, 6, 'Egg Fried Rice', 'Fragrant rice dish cooked with whole spices', 480, 12, 510, 0, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (39, 6, 'Steamed Rice', 'Fragrant rice dish cooked with whole spices', 250, 10, 330, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (40, 7, 'Plain Naan', 'Freshly baked in the tandoor', 60, 5, 180, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (41, 7, 'Garlic Naan', 'Freshly baked in the tandoor', 120, 6, 220, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (42, 7, 'Tandoori Roti', 'Freshly baked in the tandoor', 50, 4, 120, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (43, 7, 'Lachha Paratha', 'Freshly baked in the tandoor', 90, 6, 260, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (44, 8, 'Gulab Jamun (2 pcs)', 'Traditional sweet dessert', 280, 5, 340, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (45, 8, 'Kheer', 'Traditional sweet dessert', 250, 5, 310, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (46, 8, 'Chocolate Brownie', 'Traditional sweet dessert', 450, 8, 470, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (47, 8, 'Ras Malai (2 pcs)', 'Traditional sweet dessert', 380, 5, 290, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (48, 8, 'Kulfi Falooda', 'Traditional sweet dessert', 420, 6, 380, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (49, 8, 'Gajar Halwa', 'Traditional sweet dessert', 350, 6, 360, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (50, 9, 'Mint Margarita', 'Refreshing house beverage', 280, 5, 120, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (51, 9, 'Sweet Lassi', 'Refreshing house beverage', 300, 5, 230, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (52, 9, 'Fresh Lime Soda', 'Refreshing house beverage', 250, 4, 90, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (53, 9, 'Mango Shake', 'Refreshing house beverage', 420, 5, 310, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (54, 9, 'Kashmiri Chai', 'Refreshing house beverage', 220, 6, 110, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (55, 9, 'Cold Coffee', 'Refreshing house beverage', 450, 6, 260, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (56, 9, 'Soft Drink (345ml)', 'Refreshing house beverage', 150, 1, 140, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (57, 9, 'Mineral Water (500ml)', 'Refreshing house beverage', 100, 1, 0, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (58, 10, 'Chicken Nuggets (6 pcs)', 'Kid-friendly portion with mild flavour', 550, 12, 330, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (59, 10, 'Mini Cheese Pizza', 'Kid-friendly portion with mild flavour', 650, 15, 420, 1, 0);
INSERT INTO MENU_ITEM (MenuItem_ID, Category_ID, Name, Description, UnitPrice, PreparationTime, Calories, IsAvailable, IsSpicy) VALUES (60, 10, 'French Fries', 'Kid-friendly portion with mild flavour', 300, 8, 360, 1, 0);

-- INVENTORY_ITEM (50 rows)
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (1, 'Chicken Breast', 109.4, 'kg', 40, 520, TO_DATE('2026-11-14','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (2, 'Chicken Whole', 109.3, 'kg', 40, 380, TO_DATE('2026-10-20','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (3, 'Mutton', 57.8, 'kg', 15, 2100, TO_DATE('2026-11-08','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (4, 'Beef', 151.52, 'kg', 40, 1250, TO_DATE('2026-10-15','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (5, 'Fish Fillet', 95.2, 'kg', 40, 1100, TO_DATE('2026-10-25','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (6, 'Basmati Rice', 74.85, 'kg', 20, 360, TO_DATE('2026-11-17','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (7, 'Wheat Flour', 80.9, 'kg', 30, 110, TO_DATE('2026-10-24','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (8, 'Refined Flour (Maida)', 188.27, 'kg', 50, 120, TO_DATE('2026-10-24','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (9, 'Cooking Oil', 96.19, 'litre', 30, 520, TO_DATE('2026-10-21','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (10, 'Desi Ghee', 113.7, 'kg', 40, 1800, TO_DATE('2026-11-16','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (11, 'Onion', 56.5, 'kg', 15, 90, TO_DATE('2026-10-20','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (12, 'Tomato', 16.38, 'kg', 30, 120, TO_DATE('2026-11-03','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (13, 'Potato', 61.68, 'kg', 30, 80, TO_DATE('2026-11-13','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (14, 'Ginger', 31.24, 'kg', 10, 450, TO_DATE('2026-10-21','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (15, 'Garlic', 35.07, 'kg', 40, 600, TO_DATE('2026-10-22','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (16, 'Green Chilli', 127.52, 'kg', 40, 250, TO_DATE('2026-10-30','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (17, 'Coriander', 12.29, 'bunch', 10, 40, TO_DATE('2026-10-28','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (18, 'Mint', 49.49, 'bunch', 15, 30, TO_DATE('2026-11-05','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (19, 'Lemon', 34.56, 'kg', 20, 300, TO_DATE('2026-11-08','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (20, 'Yogurt', 55.52, 'kg', 20, 240, TO_DATE('2026-11-05','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (21, 'Fresh Milk', 44.11, 'litre', 15, 190, TO_DATE('2026-10-23','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (22, 'Cream', 26.11, 'litre', 15, 700, TO_DATE('2026-10-17','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (23, 'Butter', 18.34, 'kg', 10, 1700, TO_DATE('2026-10-25','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (24, 'Eggs', 56.67, 'dozen', 15, 380, TO_DATE('2026-11-11','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (25, 'Paneer', 80.72, 'kg', 50, 1400, TO_DATE('2026-11-08','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (26, 'Spinach', 92.88, 'kg', 40, 150, TO_DATE('2026-11-04','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (27, 'Mushrooms', 42.54, 'kg', 20, 800, TO_DATE('2026-11-05','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (28, 'Cabbage', 67.72, 'kg', 30, 90, TO_DATE('2026-11-16','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (29, 'Carrot', 14.73, 'kg', 20, 110, TO_DATE('2026-11-03','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (30, 'Capsicum', 95.93, 'kg', 30, 280, TO_DATE('2026-11-17','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (31, 'Lettuce', 26.46, 'kg', 40, 350, TO_DATE('2026-10-20','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (32, 'Cucumber', 85.36, 'kg', 40, 100, TO_DATE('2026-10-20','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (33, 'Red Chilli Powder', 22.04, 'kg', 25, 900, TO_DATE('2026-10-23','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (34, 'Turmeric Powder', 112.87, 'kg', 30, 700, TO_DATE('2026-10-25','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (35, 'Garam Masala', 38.15, 'kg', 10, 1500, TO_DATE('2026-10-15','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (36, 'Cumin Seeds', 140.3, 'kg', 50, 1100, TO_DATE('2026-10-25','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (37, 'Salt', 32.24, 'kg', 25, 60, TO_DATE('2026-10-26','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (38, 'Black Pepper', 85.72, 'kg', 30, 2200, TO_DATE('2026-10-16','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (39, 'Sugar', 3.0, 'kg', 10, 140, TO_DATE('2026-11-08','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (40, 'Cocoa Powder', 53.11, 'kg', 20, 1900, TO_DATE('2026-10-31','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (41, 'Mango Pulp', 135.81, 'kg', 40, 450, TO_DATE('2026-10-24','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (42, 'Tea Leaves', 54.18, 'kg', 25, 1200, TO_DATE('2026-11-10','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (43, 'Coffee Beans', 120.75, 'kg', 50, 3200, TO_DATE('2026-10-22','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (44, 'Soft Drink Cans', 746.4, 'pcs', 200, 65, TO_DATE('2026-11-04','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (45, 'Mineral Water Bottles', 225.42, 'pcs', 100, 45, TO_DATE('2026-11-04','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (46, 'Red Lentils (Masoor)', 7.91, 'kg', 10, 280, TO_DATE('2026-10-30','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (47, 'Black Lentils (Maash)', 59.8, 'kg', 40, 420, TO_DATE('2026-10-30','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (48, 'Spring Roll Sheets', 54.95, 'pack', 15, 280, TO_DATE('2026-11-07','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (49, 'Cheese (Mozzarella)', 45.28, 'kg', 15, 1600, TO_DATE('2026-11-10','YYYY-MM-DD'));
INSERT INTO INVENTORY_ITEM (InventoryItem_ID, ItemName, QuantityInStock, UnitOfMeasure, ReorderThreshold, CostPerUnit, LastRestockDate) VALUES (50, 'Dry Fruits Mix', 22.64, 'kg', 30, 2800, TO_DATE('2026-10-22','YYYY-MM-DD'));

-- MENU_DISCOUNT (30 rows)
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (1, 57, 'Student Discount', 10, TO_DATE('2026-09-29','YYYY-MM-DD'), TO_DATE('2026-11-08','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (2, 35, 'Family Combo', 30, TO_DATE('2026-06-16','YYYY-MM-DD'), TO_DATE('2026-07-25','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (3, 37, 'Weekend Special', 10, TO_DATE('2026-08-30','YYYY-MM-DD'), TO_DATE('2026-11-12','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (4, 30, 'Loyalty Reward', 25, TO_DATE('2026-10-22','YYYY-MM-DD'), TO_DATE('2026-11-30','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (5, 1, 'Weekend Special', 25, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_DATE('2026-09-07','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (6, 19, 'Family Combo', 10, TO_DATE('2026-06-28','YYYY-MM-DD'), TO_DATE('2026-08-20','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (7, 16, 'Ramadan Deal', 10, TO_DATE('2026-09-16','YYYY-MM-DD'), TO_DATE('2026-12-30','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (8, 47, 'Happy Hour', 10, TO_DATE('2026-09-22','YYYY-MM-DD'), TO_DATE('2026-11-28','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (9, 20, 'Happy Hour', 25, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_DATE('2026-09-19','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (10, 2, 'Ramadan Deal', 25, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_DATE('2026-09-07','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (11, 21, 'Launch Offer', 30, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_DATE('2026-10-17','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (12, 12, 'Loyalty Reward', 5, TO_DATE('2026-08-09','YYYY-MM-DD'), TO_DATE('2026-10-09','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (13, 5, 'Student Discount', 10, TO_DATE('2026-10-30','YYYY-MM-DD'), TO_DATE('2027-01-18','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (14, 29, 'Student Discount', 10, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_DATE('2026-10-24','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (15, 53, 'Happy Hour', 15, TO_DATE('2026-07-04','YYYY-MM-DD'), TO_DATE('2026-10-07','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (16, 34, 'Loyalty Reward', 5, TO_DATE('2026-06-20','YYYY-MM-DD'), TO_DATE('2026-08-29','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (17, 26, 'Weekend Special', 20, TO_DATE('2026-10-14','YYYY-MM-DD'), TO_DATE('2026-11-02','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (18, 10, 'Loyalty Reward', 10, TO_DATE('2026-10-29','YYYY-MM-DD'), TO_DATE('2026-12-18','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (19, 23, 'Chef Special', 5, TO_DATE('2026-09-17','YYYY-MM-DD'), TO_DATE('2027-01-11','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (20, 38, 'Student Discount', 10, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_DATE('2026-09-01','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (21, 15, 'Loyalty Reward', 5, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_DATE('2026-09-03','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (22, 3, 'Ramadan Deal', 5, TO_DATE('2026-07-18','YYYY-MM-DD'), TO_DATE('2026-11-10','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (23, 52, 'Chef Special', 15, TO_DATE('2026-09-27','YYYY-MM-DD'), TO_DATE('2027-01-15','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (24, 51, 'Weekend Special', 10, TO_DATE('2026-06-01','YYYY-MM-DD'), TO_DATE('2026-08-17','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (25, 60, 'Family Combo', 10, TO_DATE('2026-06-17','YYYY-MM-DD'), TO_DATE('2026-09-10','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (26, 50, 'Weekend Special', 20, TO_DATE('2026-10-02','YYYY-MM-DD'), TO_DATE('2027-01-24','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (27, 41, 'Loyalty Reward', 25, TO_DATE('2026-08-14','YYYY-MM-DD'), TO_DATE('2026-10-31','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (28, 59, 'Chef Special', 30, TO_DATE('2026-10-15','YYYY-MM-DD'), TO_DATE('2026-11-20','YYYY-MM-DD'), 1);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (29, 32, 'Chef Special', 15, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_DATE('2026-08-10','YYYY-MM-DD'), 0);
INSERT INTO MENU_DISCOUNT (Discount_ID, MenuItem_ID, DiscountName, Percentage, StartDate, EndDate, IsActive) VALUES (30, 48, 'Festive Offer', 20, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_DATE('2026-11-07','YYYY-MM-DD'), 0);

-- RECIPE_INGREDIENT (98 rows)
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (1, 1, 13, 0.148, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (2, 1, 8, 0.232, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (3, 2, 11, 0.292, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (4, 2, 13, 0.201, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (5, 3, 33, 0.129, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (6, 4, 20, 0.059, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (7, 5, 1, 0.221, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (8, 5, 8, 0.213, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (9, 6, 20, 0.121, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (10, 6, 33, 0.094, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (11, 7, 9, 0.056, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (12, 7, 13, 0.144, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (13, 8, 11, 0.208, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (14, 8, 33, 0.129, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (15, 9, 46, 0.077, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (16, 9, 38, 0.296, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (17, 10, 12, 0.126, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (18, 10, 38, 0.098, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (19, 11, 28, 0.299, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (20, 11, 15, 0.286, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (21, 12, 2, 0.173, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (22, 12, 37, 0.159, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (23, 13, 32, 0.261, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (24, 14, 31, 0.197, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (25, 14, 32, 0.278, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (26, 15, 32, 0.093, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (27, 16, 19, 0.207, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (28, 17, 1, 0.051, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (29, 18, 33, 0.077, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (30, 18, 3, 0.217, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (31, 19, 35, 0.331, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (32, 19, 33, 0.341, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (33, 20, 20, 0.126, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (34, 20, 15, 0.216, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (35, 21, 20, 0.188, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (36, 21, 33, 0.33, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (37, 22, 14, 0.151, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (38, 22, 15, 0.344, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (39, 23, 20, 0.098, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (40, 23, 1, 0.226, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (41, 24, 1, 0.22, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (42, 24, 14, 0.324, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (43, 25, 26, 0.189, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (44, 25, 4, 0.168, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (45, 26, 23, 0.164, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (46, 26, 12, 0.284, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (47, 27, 12, 0.154, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (48, 27, 15, 0.105, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (49, 28, 35, 0.099, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (50, 28, 22, 0.081, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (51, 29, 12, 0.19, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (52, 29, 26, 0.143, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (53, 30, 10, 0.348, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (54, 30, 23, 0.254, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (55, 31, 23, 0.111, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (56, 31, 10, 0.165, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (57, 32, 3, 0.064, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (58, 33, 11, 0.335, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (59, 33, 14, 0.236, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (60, 34, 35, 0.272, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (61, 34, 4, 0.204, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (62, 35, 24, 0.285, 'dozen');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (63, 36, 4, 0.131, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (64, 36, 2, 0.158, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (65, 37, 2, 0.268, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (66, 38, 20, 0.158, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (67, 39, 20, 0.122, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (68, 40, 7, 0.349, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (69, 40, 23, 0.302, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (70, 41, 10, 0.306, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (71, 41, 7, 0.164, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (72, 42, 20, 0.251, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (73, 42, 15, 0.141, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (74, 43, 15, 0.197, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (75, 43, 8, 0.106, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (76, 44, 22, 0.081, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (77, 44, 21, 0.112, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (78, 45, 23, 0.258, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (79, 45, 50, 0.205, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (80, 46, 50, 0.144, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (81, 47, 23, 0.25, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (82, 48, 22, 0.175, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (83, 48, 39, 0.21, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (84, 49, 23, 0.091, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (85, 49, 40, 0.205, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (86, 50, 42, 0.118, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (87, 51, 41, 0.161, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (88, 52, 39, 0.062, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (89, 52, 19, 0.057, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (90, 53, 21, 0.052, 'litre');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (91, 53, 41, 0.278, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (92, 54, 41, 0.248, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (93, 55, 19, 0.326, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (94, 56, 44, 1, 'pcs');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (95, 57, 45, 1, 'pcs');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (96, 58, 8, 0.217, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (97, 59, 49, 0.25, 'kg');
INSERT INTO RECIPE_INGREDIENT (Recipe_ID, MenuItem_ID, InventoryItem_ID, QuantityRequired, UnitOfMeasure) VALUES (98, 60, 49, 0.12, 'kg');

-- SHIFT_SCHEDULE (100 rows)
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (1, 5, TO_DATE('2026-11-01','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (2, 12, TO_DATE('2026-11-01','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (3, 19, TO_DATE('2026-11-02','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (4, 34, TO_DATE('2026-11-02','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (5, 35, TO_DATE('2026-11-02','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (6, 44, TO_DATE('2026-11-02','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (7, 5, TO_DATE('2026-11-03','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (8, 15, TO_DATE('2026-11-03','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (9, 30, TO_DATE('2026-11-03','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (10, 29, TO_DATE('2026-11-04','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (11, 31, TO_DATE('2026-11-04','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (12, 11, TO_DATE('2026-11-05','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (13, 48, TO_DATE('2026-11-05','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (14, 11, TO_DATE('2026-11-06','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (15, 24, TO_DATE('2026-11-06','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (16, 32, TO_DATE('2026-11-06','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (17, 34, TO_DATE('2026-11-06','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (18, 48, TO_DATE('2026-11-06','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (19, 3, TO_DATE('2026-11-07','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (20, 29, TO_DATE('2026-11-07','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (21, 49, TO_DATE('2026-11-07','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (22, 19, TO_DATE('2026-11-08','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (23, 20, TO_DATE('2026-11-08','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (24, 45, TO_DATE('2026-11-08','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (25, 50, TO_DATE('2026-11-08','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (26, 10, TO_DATE('2026-11-09','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (27, 26, TO_DATE('2026-11-09','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (28, 29, TO_DATE('2026-11-09','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (29, 30, TO_DATE('2026-11-09','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (30, 44, TO_DATE('2026-11-09','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (31, 5, TO_DATE('2026-11-10','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (32, 40, TO_DATE('2026-11-10','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (33, 45, TO_DATE('2026-11-10','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (34, 50, TO_DATE('2026-11-10','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (35, 2, TO_DATE('2026-11-11','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (36, 10, TO_DATE('2026-11-11','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (37, 26, TO_DATE('2026-11-11','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (38, 43, TO_DATE('2026-11-11','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (39, 11, TO_DATE('2026-11-12','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (40, 17, TO_DATE('2026-11-12','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (41, 8, TO_DATE('2026-11-13','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (42, 32, TO_DATE('2026-11-13','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (43, 38, TO_DATE('2026-11-13','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (44, 40, TO_DATE('2026-11-13','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (45, 47, TO_DATE('2026-11-13','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (46, 49, TO_DATE('2026-11-13','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (47, 27, TO_DATE('2026-11-14','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (48, 35, TO_DATE('2026-11-14','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (49, 38, TO_DATE('2026-11-14','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (50, 20, TO_DATE('2026-11-16','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (51, 22, TO_DATE('2026-11-16','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (52, 27, TO_DATE('2026-11-16','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (53, 38, TO_DATE('2026-11-16','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (54, 45, TO_DATE('2026-11-16','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (55, 16, TO_DATE('2026-11-17','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (56, 32, TO_DATE('2026-11-17','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (57, 48, TO_DATE('2026-11-17','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (58, 16, TO_DATE('2026-11-18','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (59, 2, TO_DATE('2026-11-19','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (60, 9, TO_DATE('2026-11-19','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (61, 19, TO_DATE('2026-11-19','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (62, 34, TO_DATE('2026-11-19','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (63, 6, TO_DATE('2026-11-20','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (64, 10, TO_DATE('2026-11-20','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (65, 28, TO_DATE('2026-11-20','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (66, 50, TO_DATE('2026-11-21','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (67, 17, TO_DATE('2026-11-22','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (68, 11, TO_DATE('2026-11-23','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (69, 14, TO_DATE('2026-11-23','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (70, 19, TO_DATE('2026-11-23','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (71, 22, TO_DATE('2026-11-23','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (72, 24, TO_DATE('2026-11-23','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (73, 27, TO_DATE('2026-11-23','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (74, 41, TO_DATE('2026-11-23','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (75, 43, TO_DATE('2026-11-23','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (76, 45, TO_DATE('2026-11-23','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (77, 6, TO_DATE('2026-11-24','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (78, 26, TO_DATE('2026-11-24','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (79, 27, TO_DATE('2026-11-24','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (80, 29, TO_DATE('2026-11-24','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (81, 36, TO_DATE('2026-11-24','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (82, 43, TO_DATE('2026-11-24','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (83, 14, TO_DATE('2026-11-25','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (84, 30, TO_DATE('2026-11-25','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (85, 45, TO_DATE('2026-11-25','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (86, 3, TO_DATE('2026-11-26','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (87, 20, TO_DATE('2026-11-26','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (88, 31, TO_DATE('2026-11-26','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (89, 49, TO_DATE('2026-11-26','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (90, 2, TO_DATE('2026-11-27','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (91, 5, TO_DATE('2026-11-27','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (92, 14, TO_DATE('2026-11-27','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (93, 35, TO_DATE('2026-11-28','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (94, 43, TO_DATE('2026-11-28','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (95, 49, TO_DATE('2026-11-28','YYYY-MM-DD'), '10:00', '22:00', 'Full Day');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (96, 24, TO_DATE('2026-11-29','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (97, 47, TO_DATE('2026-11-29','YYYY-MM-DD'), '08:00', '16:00', 'Morning');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (98, 5, TO_DATE('2026-11-30','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (99, 28, TO_DATE('2026-11-30','YYYY-MM-DD'), '16:00', '23:00', 'Evening');
INSERT INTO SHIFT_SCHEDULE (Shift_ID, Employee_ID, ShiftDate, StartTime, EndTime, ShiftType) VALUES (100, 39, TO_DATE('2026-11-30','YYYY-MM-DD'), '16:00', '23:00', 'Evening');

-- RESERVATION (70 rows)
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (1, 10, 35, TO_DATE('2026-10-02','YYYY-MM-DD'), '20:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-09-24 13:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (2, 13, 28, TO_DATE('2026-10-03','YYYY-MM-DD'), '12:00', 3, NULL, 'Completed', TO_TIMESTAMP('2026-09-24 09:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (3, 13, 54, TO_DATE('2026-10-04','YYYY-MM-DD'), '12:30', 5, NULL, 'Completed', TO_TIMESTAMP('2026-09-27 17:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (4, 67, 17, TO_DATE('2026-10-09','YYYY-MM-DD'), '13:00', 3, NULL, 'Completed', TO_TIMESTAMP('2026-09-27 14:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (5, 24, 18, TO_DATE('2026-10-09','YYYY-MM-DD'), '19:30', 2, 'High chair for infant', 'Completed', TO_TIMESTAMP('2026-10-04 14:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (6, 50, 28, TO_DATE('2026-10-09','YYYY-MM-DD'), '21:00', 4, 'High chair for infant', 'Completed', TO_TIMESTAMP('2026-10-02 17:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (7, 16, 58, TO_DATE('2026-10-10','YYYY-MM-DD'), '12:30', 8, 'Birthday celebration - need a cake table', 'Completed', TO_TIMESTAMP('2026-09-29 22:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (8, 26, 20, TO_DATE('2026-10-11','YYYY-MM-DD'), '12:00', 4, NULL, 'Completed', TO_TIMESTAMP('2026-10-05 16:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (9, 53, 19, TO_DATE('2026-10-11','YYYY-MM-DD'), '20:30', 2, NULL, 'Completed', TO_TIMESTAMP('2026-10-03 15:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (10, 56, 12, TO_DATE('2026-10-11','YYYY-MM-DD'), '20:30', 1, NULL, 'Completed', TO_TIMESTAMP('2026-10-04 21:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (11, 37, 12, TO_DATE('2026-10-13','YYYY-MM-DD'), '19:30', 1, NULL, 'Completed', TO_TIMESTAMP('2026-10-07 22:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (12, 33, 53, TO_DATE('2026-10-13','YYYY-MM-DD'), '20:30', 5, 'High chair for infant', 'Completed', TO_TIMESTAMP('2026-09-29 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (13, 46, 49, TO_DATE('2026-10-14','YYYY-MM-DD'), '19:00', 1, NULL, 'No-Show', TO_TIMESTAMP('2026-09-30 11:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (14, 3, 24, TO_DATE('2026-10-14','YYYY-MM-DD'), '19:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-10-12 12:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (15, 53, 55, TO_DATE('2026-10-14','YYYY-MM-DD'), '21:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-10-11 18:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (16, 66, 37, TO_DATE('2026-10-16','YYYY-MM-DD'), '12:30', 3, 'Quiet corner', 'Completed', TO_TIMESTAMP('2026-10-13 19:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (17, 36, 13, TO_DATE('2026-10-19','YYYY-MM-DD'), '12:30', 4, 'Birthday celebration - need a cake table', 'Completed', TO_TIMESTAMP('2026-10-12 14:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (18, 47, 35, TO_DATE('2026-10-21','YYYY-MM-DD'), '21:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-10-16 09:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (19, 60, 1, TO_DATE('2026-10-22','YYYY-MM-DD'), '19:00', 1, 'Wheelchair accessible table', 'Cancelled', TO_TIMESTAMP('2026-10-09 10:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (20, 41, 21, TO_DATE('2026-10-26','YYYY-MM-DD'), '21:00', 5, NULL, 'Completed', TO_TIMESTAMP('2026-10-19 09:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (21, 22, 14, TO_DATE('2026-10-26','YYYY-MM-DD'), '21:00', 3, NULL, 'Completed', TO_TIMESTAMP('2026-10-24 11:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (22, 42, 54, TO_DATE('2026-10-27','YYYY-MM-DD'), '12:00', 6, NULL, 'Completed', TO_TIMESTAMP('2026-10-21 10:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (23, 6, 14, TO_DATE('2026-10-27','YYYY-MM-DD'), '13:00', 2, 'Anniversary dinner', 'Completed', TO_TIMESTAMP('2026-10-24 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (24, 16, 60, TO_DATE('2026-10-28','YYYY-MM-DD'), '12:30', 6, NULL, 'Completed', TO_TIMESTAMP('2026-10-22 17:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (25, 66, 51, TO_DATE('2026-10-28','YYYY-MM-DD'), '21:00', 6, 'Birthday celebration - need a cake table', 'Completed', TO_TIMESTAMP('2026-10-20 14:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (26, 62, 26, TO_DATE('2026-10-29','YYYY-MM-DD'), '12:30', 2, NULL, 'Completed', TO_TIMESTAMP('2026-10-28 14:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (27, 21, 1, TO_DATE('2026-10-30','YYYY-MM-DD'), '13:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-10-18 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (28, 50, 1, TO_DATE('2026-11-01','YYYY-MM-DD'), '12:00', 2, 'Birthday celebration - need a cake table', 'Completed', TO_TIMESTAMP('2026-10-26 11:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (29, 22, 56, TO_DATE('2026-11-01','YYYY-MM-DD'), '20:30', 1, NULL, 'Completed', TO_TIMESTAMP('2026-10-29 22:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (30, 7, 22, TO_DATE('2026-11-02','YYYY-MM-DD'), '19:30', 2, NULL, 'Completed', TO_TIMESTAMP('2026-10-21 16:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (31, 62, 20, TO_DATE('2026-11-04','YYYY-MM-DD'), '19:00', 4, NULL, 'Completed', TO_TIMESTAMP('2026-10-29 10:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (32, 70, 51, TO_DATE('2026-11-05','YYYY-MM-DD'), '21:00', 4, NULL, 'Completed', TO_TIMESTAMP('2026-10-22 15:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (33, 51, 51, TO_DATE('2026-11-06','YYYY-MM-DD'), '19:00', 3, NULL, 'Completed', TO_TIMESTAMP('2026-10-24 16:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (34, 63, 17, TO_DATE('2026-11-07','YYYY-MM-DD'), '19:00', 1, 'Anniversary dinner', 'Completed', TO_TIMESTAMP('2026-10-29 11:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (35, 19, 35, TO_DATE('2026-11-08','YYYY-MM-DD'), '13:30', 2, NULL, 'Completed', TO_TIMESTAMP('2026-11-02 10:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (36, 47, 15, TO_DATE('2026-11-11','YYYY-MM-DD'), '20:00', 6, NULL, 'Completed', TO_TIMESTAMP('2026-11-02 19:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (37, 21, 28, TO_DATE('2026-11-12','YYYY-MM-DD'), '20:30', 4, NULL, 'Completed', TO_TIMESTAMP('2026-11-11 13:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (38, 62, 60, TO_DATE('2026-11-13','YYYY-MM-DD'), '12:00', 8, 'Birthday celebration - need a cake table', 'Completed', TO_TIMESTAMP('2026-11-03 17:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (39, 55, 34, TO_DATE('2026-11-14','YYYY-MM-DD'), '12:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-11-10 13:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (40, 60, 42, TO_DATE('2026-11-14','YYYY-MM-DD'), '20:00', 7, NULL, 'No-Show', TO_TIMESTAMP('2026-11-03 15:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (41, 33, 27, TO_DATE('2026-11-14','YYYY-MM-DD'), '21:00', 2, 'Anniversary dinner', 'Completed', TO_TIMESTAMP('2026-11-05 09:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (42, 37, 7, TO_DATE('2026-11-14','YYYY-MM-DD'), '21:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-11-10 16:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (43, 2, 18, TO_DATE('2026-11-15','YYYY-MM-DD'), '12:00', 2, 'Wheelchair accessible table', 'No-Show', TO_TIMESTAMP('2026-11-10 10:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (44, 47, 23, TO_DATE('2026-11-15','YYYY-MM-DD'), '19:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-11-14 10:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (45, 8, 50, TO_DATE('2026-11-15','YYYY-MM-DD'), '21:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-11-12 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (46, 35, 5, TO_DATE('2026-11-16','YYYY-MM-DD'), '20:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-11-11 18:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (47, 9, 13, TO_DATE('2026-11-16','YYYY-MM-DD'), '21:00', 1, NULL, 'Completed', TO_TIMESTAMP('2026-11-07 09:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (48, 20, 2, TO_DATE('2026-11-17','YYYY-MM-DD'), '12:00', 6, 'High chair for infant', 'Completed', TO_TIMESTAMP('2026-11-03 22:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (49, 41, 24, TO_DATE('2026-11-17','YYYY-MM-DD'), '19:00', 2, NULL, 'Completed', TO_TIMESTAMP('2026-11-07 21:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (50, 12, 40, TO_DATE('2026-11-19','YYYY-MM-DD'), '12:00', 8, NULL, 'Cancelled', TO_TIMESTAMP('2026-11-11 16:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (51, 66, 27, TO_DATE('2026-11-19','YYYY-MM-DD'), '21:00', 1, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-12 18:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (52, 50, 2, TO_DATE('2026-11-21','YYYY-MM-DD'), '12:30', 6, 'Quiet corner', 'Pending', TO_TIMESTAMP('2026-11-16 17:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (53, 64, 31, TO_DATE('2026-11-22','YYYY-MM-DD'), '12:00', 6, NULL, 'Pending', TO_TIMESTAMP('2026-11-15 12:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (54, 9, 26, TO_DATE('2026-11-25','YYYY-MM-DD'), '13:30', 4, NULL, 'Pending', TO_TIMESTAMP('2026-11-13 10:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (55, 59, 23, TO_DATE('2026-11-26','YYYY-MM-DD'), '20:00', 2, NULL, 'Pending', TO_TIMESTAMP('2026-11-16 10:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (56, 42, 29, TO_DATE('2026-11-27','YYYY-MM-DD'), '19:00', 4, NULL, 'Cancelled', TO_TIMESTAMP('2026-11-26 18:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (57, 30, 10, TO_DATE('2026-12-01','YYYY-MM-DD'), '20:00', 2, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-29 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (58, 1, 34, TO_DATE('2026-12-02','YYYY-MM-DD'), '12:00', 2, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-25 18:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (59, 15, 58, TO_DATE('2026-12-02','YYYY-MM-DD'), '12:30', 5, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-29 22:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (60, 13, 22, TO_DATE('2026-12-02','YYYY-MM-DD'), '13:00', 2, NULL, 'Pending', TO_TIMESTAMP('2026-11-19 14:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (61, 9, 51, TO_DATE('2026-12-02','YYYY-MM-DD'), '13:30', 4, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-19 16:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (62, 50, 15, TO_DATE('2026-12-03','YYYY-MM-DD'), '20:00', 5, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-19 13:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (63, 29, 30, TO_DATE('2026-12-04','YYYY-MM-DD'), '19:30', 1, NULL, 'Pending', TO_TIMESTAMP('2026-11-23 19:00:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (64, 42, 25, TO_DATE('2026-12-05','YYYY-MM-DD'), '20:30', 2, 'High chair for infant', 'Confirmed', TO_TIMESTAMP('2026-11-26 20:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (65, 52, 1, TO_DATE('2026-12-07','YYYY-MM-DD'), '19:00', 2, NULL, 'Confirmed', TO_TIMESTAMP('2026-11-24 20:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (66, 18, 17, TO_DATE('2026-12-08','YYYY-MM-DD'), '12:30', 1, NULL, 'Pending', TO_TIMESTAMP('2026-12-02 16:15:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (67, 49, 27, TO_DATE('2026-12-13','YYYY-MM-DD'), '12:00', 1, NULL, 'Confirmed', TO_TIMESTAMP('2026-12-11 21:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (68, 43, 19, TO_DATE('2026-12-13','YYYY-MM-DD'), '12:30', 1, 'High chair for infant', 'Confirmed', TO_TIMESTAMP('2026-12-06 12:30:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (69, 27, 53, TO_DATE('2026-12-15','YYYY-MM-DD'), '12:30', 5, NULL, 'Pending', TO_TIMESTAMP('2026-12-04 10:45:00','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO RESERVATION (Reservation_ID, Customer_ID, Table_ID, ReservationDate, ReservationTime, NumberOfPeople, SpecialRequests, Status, CreatedAt) VALUES (70, 22, 16, TO_DATE('2026-12-15','YYYY-MM-DD'), '20:00', 1, NULL, 'Pending', TO_TIMESTAMP('2026-12-14 12:45:00','YYYY-MM-DD HH24:MI:SS'));

-- PURCHASE_ORDER (50 rows)
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (1, 9, 1, TO_DATE('2026-08-02','YYYY-MM-DD'), TO_DATE('2026-08-08','YYYY-MM-DD'), 68410.82, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (2, 19, 2, TO_DATE('2026-08-04','YYYY-MM-DD'), TO_DATE('2026-08-11','YYYY-MM-DD'), 52425.18, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (3, 2, 2, TO_DATE('2026-08-04','YYYY-MM-DD'), TO_DATE('2026-08-07','YYYY-MM-DD'), 59586.2, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (4, 4, 3, TO_DATE('2026-08-05','YYYY-MM-DD'), TO_DATE('2026-08-09','YYYY-MM-DD'), 91697.51, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (5, 3, 4, TO_DATE('2026-08-05','YYYY-MM-DD'), TO_DATE('2026-08-08','YYYY-MM-DD'), 21299.32, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (6, 1, 1, TO_DATE('2026-08-09','YYYY-MM-DD'), TO_DATE('2026-08-14','YYYY-MM-DD'), 251789.6, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (7, 4, 5, TO_DATE('2026-08-10','YYYY-MM-DD'), TO_DATE('2026-08-17','YYYY-MM-DD'), 247177.05, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (8, 17, 2, TO_DATE('2026-08-12','YYYY-MM-DD'), TO_DATE('2026-08-17','YYYY-MM-DD'), 21788.53, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (9, 8, 3, TO_DATE('2026-08-18','YYYY-MM-DD'), TO_DATE('2026-08-21','YYYY-MM-DD'), 436135.35, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (10, 15, 3, TO_DATE('2026-08-18','YYYY-MM-DD'), TO_DATE('2026-08-22','YYYY-MM-DD'), 41238.66, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (11, 7, 2, TO_DATE('2026-08-19','YYYY-MM-DD'), TO_DATE('2026-08-24','YYYY-MM-DD'), 53384.12, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (12, 2, 2, TO_DATE('2026-08-19','YYYY-MM-DD'), TO_DATE('2026-08-22','YYYY-MM-DD'), 24317.8, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (13, 17, 3, TO_DATE('2026-08-24','YYYY-MM-DD'), TO_DATE('2026-08-30','YYYY-MM-DD'), 27038.29, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (14, 2, 1, TO_DATE('2026-08-24','YYYY-MM-DD'), TO_DATE('2026-08-28','YYYY-MM-DD'), 28930.82, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (15, 7, 3, TO_DATE('2026-08-26','YYYY-MM-DD'), TO_DATE('2026-08-31','YYYY-MM-DD'), 49364.45, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (16, 14, 5, TO_DATE('2026-08-28','YYYY-MM-DD'), TO_DATE('2026-08-31','YYYY-MM-DD'), 98605.8, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (17, 11, 2, TO_DATE('2026-08-29','YYYY-MM-DD'), TO_DATE('2026-09-01','YYYY-MM-DD'), 341215.81, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (18, 3, 3, TO_DATE('2026-08-29','YYYY-MM-DD'), TO_DATE('2026-09-05','YYYY-MM-DD'), 547708.46, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (19, 8, 3, TO_DATE('2026-09-02','YYYY-MM-DD'), TO_DATE('2026-09-05','YYYY-MM-DD'), 25569.96, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (20, 3, 3, TO_DATE('2026-09-09','YYYY-MM-DD'), TO_DATE('2026-09-15','YYYY-MM-DD'), 11315.26, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (21, 3, 5, TO_DATE('2026-09-10','YYYY-MM-DD'), TO_DATE('2026-09-13','YYYY-MM-DD'), 15135.78, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (22, 19, 1, TO_DATE('2026-09-11','YYYY-MM-DD'), TO_DATE('2026-09-15','YYYY-MM-DD'), 94626.72, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (23, 2, 2, TO_DATE('2026-09-12','YYYY-MM-DD'), TO_DATE('2026-09-18','YYYY-MM-DD'), 199133.77, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (24, 8, 3, TO_DATE('2026-09-14','YYYY-MM-DD'), TO_DATE('2026-09-19','YYYY-MM-DD'), 167216.8, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (25, 2, 1, TO_DATE('2026-09-15','YYYY-MM-DD'), TO_DATE('2026-09-18','YYYY-MM-DD'), 127284.7, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (26, 8, 4, TO_DATE('2026-09-15','YYYY-MM-DD'), TO_DATE('2026-09-18','YYYY-MM-DD'), 161238.26, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (27, 11, 5, TO_DATE('2026-09-17','YYYY-MM-DD'), TO_DATE('2026-09-24','YYYY-MM-DD'), 67880.12, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (28, 3, 1, TO_DATE('2026-09-17','YYYY-MM-DD'), TO_DATE('2026-09-22','YYYY-MM-DD'), 17614.99, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (29, 18, 5, TO_DATE('2026-09-18','YYYY-MM-DD'), TO_DATE('2026-09-25','YYYY-MM-DD'), 158855.8, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (30, 11, 2, TO_DATE('2026-10-01','YYYY-MM-DD'), TO_DATE('2026-10-04','YYYY-MM-DD'), 105597.44, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (31, 3, 4, TO_DATE('2026-10-02','YYYY-MM-DD'), TO_DATE('2026-10-04','YYYY-MM-DD'), 57035.94, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (32, 19, 5, TO_DATE('2026-10-02','YYYY-MM-DD'), TO_DATE('2026-10-08','YYYY-MM-DD'), 120270.58, 'Cancelled');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (33, 4, 4, TO_DATE('2026-10-03','YYYY-MM-DD'), TO_DATE('2026-10-06','YYYY-MM-DD'), 18077.52, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (34, 19, 3, TO_DATE('2026-10-04','YYYY-MM-DD'), TO_DATE('2026-10-07','YYYY-MM-DD'), 163268.16, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (35, 6, 3, TO_DATE('2026-10-04','YYYY-MM-DD'), TO_DATE('2026-10-11','YYYY-MM-DD'), 69860.1, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (36, 18, 5, TO_DATE('2026-10-07','YYYY-MM-DD'), TO_DATE('2026-10-12','YYYY-MM-DD'), 76312.34, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (37, 14, 1, TO_DATE('2026-10-09','YYYY-MM-DD'), TO_DATE('2026-10-15','YYYY-MM-DD'), 85910.13, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (38, 3, 2, TO_DATE('2026-10-11','YYYY-MM-DD'), TO_DATE('2026-10-15','YYYY-MM-DD'), 66080.46, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (39, 7, 3, TO_DATE('2026-10-12','YYYY-MM-DD'), TO_DATE('2026-10-16','YYYY-MM-DD'), 192241.59, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (40, 10, 4, TO_DATE('2026-10-12','YYYY-MM-DD'), TO_DATE('2026-10-18','YYYY-MM-DD'), 284466.24, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (41, 19, 1, TO_DATE('2026-10-13','YYYY-MM-DD'), TO_DATE('2026-10-16','YYYY-MM-DD'), 94241.42, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (42, 9, 5, TO_DATE('2026-10-26','YYYY-MM-DD'), TO_DATE('2026-11-01','YYYY-MM-DD'), 136556.06, 'Cancelled');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (43, 12, 2, TO_DATE('2026-10-27','YYYY-MM-DD'), TO_DATE('2026-11-03','YYYY-MM-DD'), 51095.23, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (44, 17, 5, TO_DATE('2026-10-28','YYYY-MM-DD'), TO_DATE('2026-11-04','YYYY-MM-DD'), 58413.93, 'Cancelled');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (45, 9, 2, TO_DATE('2026-11-02','YYYY-MM-DD'), TO_DATE('2026-11-04','YYYY-MM-DD'), 157133.71, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (46, 10, 1, TO_DATE('2026-11-04','YYYY-MM-DD'), TO_DATE('2026-11-06','YYYY-MM-DD'), 66343.63, 'Delivered');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (47, 3, 1, TO_DATE('2026-11-06','YYYY-MM-DD'), TO_DATE('2026-11-13','YYYY-MM-DD'), 263738.76, 'In Transit');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (48, 14, 5, TO_DATE('2026-11-09','YYYY-MM-DD'), TO_DATE('2026-11-16','YYYY-MM-DD'), 128338.21, 'Pending');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (49, 13, 2, TO_DATE('2026-11-10','YYYY-MM-DD'), TO_DATE('2026-11-15','YYYY-MM-DD'), 118899.28, 'Pending');
INSERT INTO PURCHASE_ORDER (PurchaseOrder_ID, Supplier_ID, Employee_ID, OrderDate, ExpectedDelivery, TotalCost, Status) VALUES (50, 1, 3, TO_DATE('2026-11-12','YYYY-MM-DD'), TO_DATE('2026-11-14','YYYY-MM-DD'), 11557.65, 'Pending');

-- PURCHASE_ORDER_DETAIL (100 rows)
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (1, 1, 30, 90, 299.38);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (2, 1, 23, 26, 1594.87);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (3, 2, 31, 62, 368.39);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (4, 2, 44, 500, 59.17);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (5, 3, 11, 28, 94.25);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (6, 3, 3, 30, 1898.24);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (7, 4, 15, 139, 599.9);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (8, 4, 28, 93, 89.37);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (9, 5, 12, 46, 115.3);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (10, 5, 22, 24, 666.48);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (11, 6, 40, 48, 1889.71);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (12, 6, 36, 152, 1059.76);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (13, 7, 23, 37, 1727.53);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (14, 7, 10, 101, 1814.44);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (15, 8, 30, 69, 303.17);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (16, 8, 17, 20, 43.49);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (17, 9, 43, 133, 3239.31);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (18, 9, 11, 56, 94.77);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (19, 10, 47, 83, 427.02);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (20, 10, 21, 28, 207.0);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (21, 11, 19, 34, 311.24);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (22, 11, 41, 94, 455.34);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (23, 12, 32, 152, 100.28);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (24, 12, 48, 36, 252.09);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (25, 13, 32, 86, 101.48);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (26, 13, 26, 123, 148.87);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (27, 14, 6, 54, 358.69);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (28, 14, 21, 46, 207.86);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (29, 15, 18, 39, 27.51);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (30, 15, 35, 34, 1420.34);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (31, 16, 26, 85, 162.08);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (32, 16, 3, 41, 2069.0);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (33, 17, 36, 193, 1097.77);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (34, 17, 4, 108, 1197.65);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (35, 18, 43, 137, 3472.85);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (36, 18, 33, 77, 934.13);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (37, 19, 29, 78, 119.18);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (38, 19, 20, 64, 254.28);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (39, 20, 46, 35, 296.87);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (40, 20, 18, 29, 31.89);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (41, 21, 20, 42, 260.14);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (42, 21, 46, 15, 280.66);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (43, 22, 22, 52, 715.47);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (44, 22, 31, 151, 380.28);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (45, 23, 42, 98, 1118.34);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (46, 23, 5, 85, 1053.37);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (47, 24, 25, 106, 1430.9);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (48, 24, 20, 68, 228.55);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (49, 25, 46, 31, 293.95);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (50, 25, 40, 63, 1875.75);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (51, 26, 27, 49, 840.29);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (52, 26, 50, 45, 2668.09);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (53, 27, 32, 152, 94.5);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (54, 27, 41, 131, 408.52);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (55, 28, 11, 52, 85.12);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (56, 28, 32, 125, 105.51);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (57, 29, 45, 278, 43.34);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (58, 29, 10, 87, 1687.44);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (59, 30, 42, 80, 1306.13);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (60, 30, 18, 34, 32.56);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (61, 31, 2, 113, 386.13);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (62, 31, 19, 45, 297.85);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (63, 32, 4, 70, 1179.38);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (64, 32, 22, 59, 639.22);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (65, 33, 7, 85, 109.41);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (66, 33, 46, 33, 265.99);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (67, 34, 13, 72, 78.94);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (68, 34, 38, 74, 2129.52);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (69, 35, 23, 28, 1852.63);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (70, 35, 19, 61, 294.86);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (71, 36, 27, 69, 866.65);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (72, 36, 16, 67, 246.47);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (73, 37, 31, 101, 359.05);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (74, 37, 44, 704, 70.52);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (75, 38, 33, 74, 885.54);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (76, 38, 17, 15, 36.7);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (77, 39, 12, 119, 122.77);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (78, 39, 50, 58, 3062.62);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (79, 40, 47, 132, 404.82);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (80, 40, 38, 102, 2265.0);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (81, 41, 46, 26, 276.22);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (82, 41, 4, 70, 1243.71);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (83, 42, 17, 28, 36.02);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (84, 42, 4, 106, 1278.75);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (85, 43, 9, 82, 549.61);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (86, 43, 28, 63, 95.67);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (87, 44, 16, 146, 245.44);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (88, 44, 44, 343, 65.83);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (89, 45, 16, 117, 245.13);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (90, 45, 4, 98, 1310.75);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (91, 46, 47, 121, 395.47);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (92, 46, 30, 63, 293.52);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (93, 47, 38, 114, 2260.74);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (94, 47, 21, 35, 171.84);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (95, 48, 47, 117, 440.09);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (96, 48, 33, 91, 844.48);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (97, 49, 3, 49, 2078.32);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (98, 49, 6, 48, 355.45);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (99, 50, 29, 45, 112.72);
INSERT INTO PURCHASE_ORDER_DETAIL (PODetail_ID, PurchaseOrder_ID, InventoryItem_ID, QuantityOrdered, UnitPrice) VALUES (100, 50, 28, 75, 86.47);

-- ORDERS (60 rows)
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (1, NULL, 31, 4, 2, TO_DATE('2026-09-03','YYYY-MM-DD'), '14:35', 'Completed', 5869.6, 809.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (2, 13, 19, 8, 1, TO_DATE('2026-09-04','YYYY-MM-DD'), '12:55', 'Completed', 2459.2, 339.2, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (3, 59, 29, NULL, 1, TO_DATE('2026-09-07','YYYY-MM-DD'), '20:15', 'Completed', 870.0, 120.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (4, NULL, 31, 22, 3, TO_DATE('2026-09-10','YYYY-MM-DD'), '19:20', 'Completed', 4558.0, 608.0, 200.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (5, 43, 14, NULL, 1, TO_DATE('2026-09-11','YYYY-MM-DD'), '17:15', 'Completed', 522.0, 72.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (6, NULL, 33, 50, 2, TO_DATE('2026-09-12','YYYY-MM-DD'), '16:20', 'Completed', 116.0, 16.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (7, 3, 27, 42, 1, TO_DATE('2026-09-12','YYYY-MM-DD'), '18:00', 'Completed', 678.6, 93.6, 65.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (8, 24, 14, 38, 1, TO_DATE('2026-09-19','YYYY-MM-DD'), '12:30', 'Completed', 1630.96, 224.96, 74.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (9, NULL, 33, 25, 3, TO_DATE('2026-09-26','YYYY-MM-DD'), '19:25', 'Completed', 1472.4, 182.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (10, 30, 24, 29, 1, TO_DATE('2026-09-28','YYYY-MM-DD'), '18:25', 'Completed', 1519.6, 209.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (11, NULL, 34, 48, 3, TO_DATE('2026-09-28','YYYY-MM-DD'), '20:25', 'Cancelled', 3688.0, 488.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (12, 28, 25, 5, 1, TO_DATE('2026-09-30','YYYY-MM-DD'), '14:35', 'Completed', 2969.6, 409.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (13, NULL, 34, 8, 3, TO_DATE('2026-09-30','YYYY-MM-DD'), '19:10', 'Completed', 1936.4, 246.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (14, 5, 17, NULL, 1, TO_DATE('2026-10-03','YYYY-MM-DD'), '19:00', 'Cancelled', 638.0, 88.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (15, NULL, 30, 18, 2, TO_DATE('2026-10-06','YYYY-MM-DD'), '19:30', 'Completed', 2784.0, 384.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (16, NULL, 32, 1, 2, TO_DATE('2026-10-09','YYYY-MM-DD'), '13:50', 'Completed', 104.4, 14.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (17, 42, 16, 5, 1, TO_DATE('2026-10-12','YYYY-MM-DD'), '13:15', 'Completed', 2238.8, 308.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (18, NULL, 30, 50, 3, TO_DATE('2026-10-14','YYYY-MM-DD'), '17:30', 'Completed', 1494.44, 185.44, 61.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (19, 39, 20, 50, 1, TO_DATE('2026-10-14','YYYY-MM-DD'), '19:25', 'Completed', 1136.8, 156.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (20, NULL, 33, 6, 2, TO_DATE('2026-10-17','YYYY-MM-DD'), '17:40', 'Completed', 139.2, 19.2, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (21, 25, 28, 47, 1, TO_DATE('2026-10-19','YYYY-MM-DD'), '13:50', 'Completed', 1450.0, 200.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (22, NULL, 31, 49, 3, TO_DATE('2026-10-19','YYYY-MM-DD'), '18:40', 'Completed', 1246.2, 151.2, 105.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (23, 12, 17, 56, 1, TO_DATE('2026-10-21','YYYY-MM-DD'), '11:40', 'Completed', 2442.96, 336.96, 234.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (24, 48, 25, 1, 1, TO_DATE('2026-10-21','YYYY-MM-DD'), '12:10', 'Cancelled', 4164.4, 574.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (25, 35, 19, NULL, 1, TO_DATE('2026-10-21','YYYY-MM-DD'), '14:40', 'Cancelled', 2204.0, 304.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (26, 51, 15, 24, 1, TO_DATE('2026-10-22','YYYY-MM-DD'), '20:55', 'Completed', 2088.0, 288.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (27, NULL, 34, NULL, 2, TO_DATE('2026-10-24','YYYY-MM-DD'), '15:10', 'Completed', 5660.8, 780.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (28, 38, 19, 50, 1, TO_DATE('2026-10-24','YYYY-MM-DD'), '18:40', 'Completed', 6554.0, 904.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (29, 39, 20, 15, 1, TO_DATE('2026-10-25','YYYY-MM-DD'), '14:15', 'Completed', 348.0, 48.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (30, 2, 15, 30, 1, TO_DATE('2026-10-26','YYYY-MM-DD'), '12:05', 'Completed', 1554.4, 214.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (31, 48, 29, 20, 1, TO_DATE('2026-10-27','YYYY-MM-DD'), '17:30', 'Completed', 1925.6, 265.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (32, 44, 27, 8, 1, TO_DATE('2026-10-29','YYYY-MM-DD'), '16:05', 'Completed', 1554.4, 214.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (33, 8, 14, 4, 1, TO_DATE('2026-10-29','YYYY-MM-DD'), '16:25', 'Completed', 1890.8, 260.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (34, NULL, 30, 48, 3, TO_DATE('2026-10-31','YYYY-MM-DD'), '18:10', 'Completed', 1588.4, 198.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (35, NULL, 33, 57, 2, TO_DATE('2026-11-01','YYYY-MM-DD'), '14:10', 'Completed', 2621.6, 361.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (36, 51, 28, 59, 1, TO_DATE('2026-11-02','YYYY-MM-DD'), '14:35', 'Completed', 6061.0, 836.0, 275.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (37, 45, 22, 20, 1, TO_DATE('2026-11-03','YYYY-MM-DD'), '17:40', 'Completed', 1032.4, 142.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (38, 59, 17, 1, 1, TO_DATE('2026-11-03','YYYY-MM-DD'), '18:30', 'Completed', 2204.0, 304.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (39, 12, 26, NULL, 1, TO_DATE('2026-11-04','YYYY-MM-DD'), '20:00', 'Completed', 2888.4, 398.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (40, 26, 29, NULL, 1, TO_DATE('2026-11-05','YYYY-MM-DD'), '11:40', 'Completed', 290.0, 40.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (41, 50, 27, NULL, 1, TO_DATE('2026-11-07','YYYY-MM-DD'), '16:45', 'Completed', 3074.0, 424.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (42, 33, 17, 37, 1, TO_DATE('2026-11-07','YYYY-MM-DD'), '17:25', 'Completed', 928.0, 128.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (43, 45, 28, 9, 1, TO_DATE('2026-11-09','YYYY-MM-DD'), '13:10', 'Completed', 290.0, 40.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (44, NULL, 33, 48, 3, TO_DATE('2026-11-10','YYYY-MM-DD'), '16:20', 'Completed', 440.0, 40.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (45, 50, 26, NULL, 1, TO_DATE('2026-11-11','YYYY-MM-DD'), '15:50', 'Cancelled', 5162.0, 712.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (46, 55, 19, NULL, 1, TO_DATE('2026-11-12','YYYY-MM-DD'), '15:05', 'Completed', 1728.4, 238.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (47, NULL, 34, 15, 3, TO_DATE('2026-11-14','YYYY-MM-DD'), '14:55', 'Completed', 1611.6, 201.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (48, 13, 29, 55, 1, TO_DATE('2026-11-15','YYYY-MM-DD'), '19:05', 'Completed', 4121.48, 568.48, 187.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (49, 6, 29, 2, 1, TO_DATE('2026-11-15','YYYY-MM-DD'), '19:15', 'Completed', 2088.0, 288.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (50, 40, 29, NULL, 1, TO_DATE('2026-11-16','YYYY-MM-DD'), '19:40', 'Completed', 3572.8, 492.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (51, NULL, 30, 5, 3, TO_DATE('2026-11-17','YYYY-MM-DD'), '12:00', 'Completed', 938.8, 108.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (52, NULL, 32, 18, 3, TO_DATE('2026-11-17','YYYY-MM-DD'), '17:50', 'Cancelled', 1170.8, 140.8, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (53, 36, 22, 28, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '19:00', 'Pending', 1305.0, 180.0, 125.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (54, 14, 22, 33, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '19:05', 'Pending', 649.6, 89.6, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (55, 35, 26, 28, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '19:10', 'Pending', 1524.24, 210.24, 146.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (56, 28, 17, NULL, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '19:45', 'Pending', 771.4, 106.4, 35.0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (57, 55, 28, 45, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '19:55', 'In Progress', 2482.4, 342.4, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (58, 34, 22, 5, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '20:05', 'In Progress', 3306.0, 456.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (59, 12, 16, 2, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '20:25', 'In Progress', 696.0, 96.0, 0);
INSERT INTO ORDERS (Order_ID, Table_ID, Employee_ID, Customer_ID, OrderType_ID, OrderDate, OrderTime, OrderStatus, TotalAmount, TaxAmount, DiscountAmount) VALUES (60, 54, 19, 63, 1, TO_DATE('2026-11-18','YYYY-MM-DD'), '21:00', 'In Progress', 1305.0, 180.0, 125.0);

-- ORDER_DETAIL (114 rows)
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (1, 1, 29, 2, 1380, 2760, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (2, 1, 31, 3, 650, 1950, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (3, 1, 49, 1, 350, 350, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (4, 2, 2, 1, 420, 420, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (5, 2, 49, 3, 350, 1050, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (6, 2, 59, 1, 650, 650, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (7, 3, 45, 1, 250, 250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (8, 3, 39, 2, 250, 500, 'Less salt', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (9, 4, 28, 3, 1250, 3750, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (10, 4, 45, 1, 250, 250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (11, 5, 56, 3, 150, 450, 'No onions', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (12, 6, 57, 1, 100, 100, 'Serve with extra raita', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (13, 7, 35, 1, 650, 650, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (14, 8, 21, 1, 780, 780, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (15, 8, 1, 2, 350, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (16, 9, 41, 2, 120, 240, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (17, 9, 55, 2, 450, 900, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (18, 10, 2, 1, 420, 420, 'Mild spice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (19, 10, 24, 1, 890, 890, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (20, 11, 6, 2, 550, 1100, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (21, 11, 31, 3, 650, 1950, 'Extra spicy', 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (22, 12, 40, 1, 60, 60, 'Extra spicy', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (23, 12, 28, 2, 1250, 2500, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (24, 13, 52, 2, 250, 500, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (25, 13, 15, 1, 250, 250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (26, 13, 5, 1, 790, 790, 'Serve with extra raita', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (27, 14, 15, 2, 250, 500, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (28, 14, 42, 1, 50, 50, 'Mild spice', 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (29, 15, 47, 3, 380, 1140, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (30, 15, 2, 3, 420, 1260, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (31, 16, 43, 1, 90, 90, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (32, 17, 44, 1, 280, 280, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (33, 17, 22, 1, 1650, 1650, 'Extra spicy', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (34, 18, 37, 1, 520, 520, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (35, 18, 1, 2, 350, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (36, 19, 44, 2, 280, 560, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (37, 19, 48, 1, 420, 420, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (38, 20, 41, 1, 120, 120, 'Well done', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (39, 21, 28, 1, 1250, 1250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (40, 22, 6, 1, 550, 550, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (41, 22, 52, 2, 250, 500, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (42, 23, 5, 2, 790, 1580, 'Mild spice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (43, 23, 47, 2, 380, 760, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (44, 24, 25, 2, 1450, 2900, 'Less salt', 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (45, 24, 3, 1, 690, 690, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (46, 25, 11, 3, 350, 1050, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (47, 25, 30, 1, 850, 850, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (48, 26, 27, 1, 1350, 1350, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (49, 26, 55, 1, 450, 450, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (50, 27, 22, 2, 1650, 3300, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (51, 27, 19, 1, 980, 980, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (52, 27, 60, 2, 300, 600, 'Mild spice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (53, 28, 22, 3, 1650, 4950, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (54, 28, 34, 1, 700, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (55, 29, 51, 1, 300, 300, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (56, 30, 15, 2, 250, 500, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (57, 30, 53, 2, 420, 840, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (58, 31, 9, 2, 380, 760, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (59, 31, 46, 2, 450, 900, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (60, 32, 7, 1, 650, 650, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (61, 32, 3, 1, 690, 690, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (62, 33, 19, 1, 980, 980, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (63, 33, 7, 1, 650, 650, 'No ice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (64, 34, 42, 2, 50, 100, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (65, 34, 47, 3, 380, 1140, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (66, 35, 21, 2, 780, 1560, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (67, 35, 36, 1, 700, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (68, 36, 39, 1, 250, 250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (69, 36, 32, 3, 1200, 3600, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (70, 36, 58, 3, 550, 1650, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (71, 37, 10, 2, 400, 800, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (72, 37, 43, 1, 90, 90, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (73, 38, 36, 1, 700, 700, 'Serve with extra raita', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (74, 38, 10, 3, 400, 1200, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (75, 39, 4, 3, 380, 1140, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (76, 39, 27, 1, 1350, 1350, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (77, 40, 45, 1, 250, 250, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (78, 41, 11, 2, 350, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (79, 41, 35, 3, 650, 1950, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (80, 42, 11, 2, 350, 700, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (81, 42, 42, 2, 50, 100, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (82, 43, 39, 1, 250, 250, 'Mild spice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (83, 44, 15, 1, 250, 250, 'Serve with extra raita', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (84, 45, 32, 3, 1200, 3600, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (85, 45, 20, 1, 850, 850, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (86, 46, 60, 2, 300, 600, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (87, 46, 24, 1, 890, 890, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (88, 47, 47, 3, 380, 1140, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (89, 47, 40, 2, 60, 120, 'No onions', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (90, 48, 25, 2, 1450, 2900, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (91, 48, 53, 2, 420, 840, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (92, 49, 35, 2, 650, 1300, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (93, 49, 45, 2, 250, 500, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (94, 50, 8, 3, 450, 1350, 'Serve with extra raita', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (95, 50, 9, 1, 380, 380, 'No ice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (96, 50, 27, 1, 1350, 1350, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (97, 51, 9, 1, 380, 380, 'No ice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (98, 51, 56, 2, 150, 300, 'Extra spicy', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (99, 52, 11, 2, 350, 700, NULL, 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (100, 52, 43, 2, 90, 180, 'Less salt', 'Cancelled');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (101, 53, 28, 1, 1250, 1250, NULL, 'Pending');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (102, 54, 50, 2, 280, 560, NULL, 'Pending');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (103, 55, 47, 2, 380, 760, 'Mild spice', 'Pending');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (104, 55, 11, 2, 350, 700, NULL, 'Pending');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (105, 56, 1, 2, 350, 700, NULL, 'Pending');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (106, 57, 35, 2, 650, 1300, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (107, 57, 2, 2, 420, 840, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (108, 58, 6, 1, 550, 550, 'Less salt', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (109, 58, 33, 1, 1950, 1950, 'Mild spice', 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (110, 58, 49, 1, 350, 350, NULL, 'Preparing');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (111, 59, 55, 1, 450, 450, NULL, 'Preparing');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (112, 59, 56, 1, 150, 150, 'Less salt', 'Preparing');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (113, 60, 6, 1, 550, 550, NULL, 'Served');
INSERT INTO ORDER_DETAIL (OrderDetail_ID, Order_ID, MenuItem_ID, Quantity, UnitPrice, SubtotalPrice, SpecialInstructions, ItemStatus) VALUES (114, 60, 36, 1, 700, 700, NULL, 'Served');

-- PAYMENT (88 rows)
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (1, 1, 2, TO_DATE('2026-09-03','YYYY-MM-DD'), '15:14', 5869.6, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (2, 2, 4, TO_DATE('2026-09-04','YYYY-MM-DD'), '13:26', 0, 0, 'Failed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (3, 2, 2, TO_DATE('2026-09-04','YYYY-MM-DD'), '14:08', 2459.2, 122.96, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (4, 3, 4, TO_DATE('2026-09-07','YYYY-MM-DD'), '21:21', 870.0, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (5, 4, 5, TO_DATE('2026-09-10','YYYY-MM-DD'), '20:14', 4558.0, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (6, 5, 4, TO_DATE('2026-09-11','YYYY-MM-DD'), '17:51', 174.0, 13.92, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (7, 5, 2, TO_DATE('2026-09-11','YYYY-MM-DD'), '18:24', 174.0, 8.7, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (8, 5, 1, TO_DATE('2026-09-11','YYYY-MM-DD'), '18:26', 174.0, 17.4, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (9, 6, 1, TO_DATE('2026-09-12','YYYY-MM-DD'), '17:19', 38.67, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (10, 6, 2, TO_DATE('2026-09-12','YYYY-MM-DD'), '17:32', 38.67, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (11, 6, 1, TO_DATE('2026-09-12','YYYY-MM-DD'), '17:34', 38.66, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (12, 7, 5, TO_DATE('2026-09-12','YYYY-MM-DD'), '18:50', 226.2, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (13, 7, 4, TO_DATE('2026-09-12','YYYY-MM-DD'), '19:13', 226.2, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (14, 7, 1, TO_DATE('2026-09-12','YYYY-MM-DD'), '19:23', 226.2, 11.31, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (15, 8, 2, TO_DATE('2026-09-19','YYYY-MM-DD'), '13:28', 815.48, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (16, 8, 1, TO_DATE('2026-09-19','YYYY-MM-DD'), '13:38', 815.48, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (17, 9, 5, TO_DATE('2026-09-26','YYYY-MM-DD'), '20:06', 1472.4, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (18, 10, 4, TO_DATE('2026-09-28','YYYY-MM-DD'), '19:50', 1519.6, 151.96, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (19, 11, 1, TO_DATE('2026-09-28','YYYY-MM-DD'), '20:45', 3688.0, 0, 'Refunded');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (20, 12, 3, TO_DATE('2026-09-30','YYYY-MM-DD'), '15:34', 989.87, 49.49, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (21, 12, 5, TO_DATE('2026-09-30','YYYY-MM-DD'), '15:39', 989.86, 98.99, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (22, 12, 4, TO_DATE('2026-09-30','YYYY-MM-DD'), '16:00', 989.87, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (23, 13, 2, TO_DATE('2026-09-30','YYYY-MM-DD'), '20:38', 1936.4, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (24, 15, 5, TO_DATE('2026-10-06','YYYY-MM-DD'), '20:08', 928.0, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (25, 15, 6, TO_DATE('2026-10-06','YYYY-MM-DD'), '20:57', 928.0, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (26, 15, 4, TO_DATE('2026-10-06','YYYY-MM-DD'), '20:57', 928.0, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (27, 16, 3, TO_DATE('2026-10-09','YYYY-MM-DD'), '14:28', 34.8, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (28, 16, 2, TO_DATE('2026-10-09','YYYY-MM-DD'), '14:33', 34.8, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (29, 16, 5, TO_DATE('2026-10-09','YYYY-MM-DD'), '15:00', 34.8, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (30, 17, 1, TO_DATE('2026-10-12','YYYY-MM-DD'), '14:00', 746.27, 74.63, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (31, 17, 5, TO_DATE('2026-10-12','YYYY-MM-DD'), '14:30', 746.26, 37.31, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (32, 17, 1, TO_DATE('2026-10-12','YYYY-MM-DD'), '14:38', 746.27, 59.7, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (33, 18, 1, TO_DATE('2026-10-14','YYYY-MM-DD'), '18:32', 1494.44, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (34, 19, 5, TO_DATE('2026-10-14','YYYY-MM-DD'), '20:14', 378.93, 30.31, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (35, 19, 4, TO_DATE('2026-10-14','YYYY-MM-DD'), '20:26', 378.94, 30.32, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (36, 19, 6, TO_DATE('2026-10-14','YYYY-MM-DD'), '20:49', 378.93, 18.95, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (37, 20, 3, TO_DATE('2026-10-17','YYYY-MM-DD'), '18:18', 139.2, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (38, 21, 2, TO_DATE('2026-10-19','YYYY-MM-DD'), '14:23', 0, 0, 'Failed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (39, 21, 2, TO_DATE('2026-10-19','YYYY-MM-DD'), '14:27', 1450.0, 116.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (40, 22, 1, TO_DATE('2026-10-19','YYYY-MM-DD'), '19:25', 415.4, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (41, 22, 1, TO_DATE('2026-10-19','YYYY-MM-DD'), '19:44', 415.4, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (42, 22, 5, TO_DATE('2026-10-19','YYYY-MM-DD'), '19:52', 415.4, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (43, 23, 3, TO_DATE('2026-10-21','YYYY-MM-DD'), '12:23', 814.32, 40.72, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (44, 23, 3, TO_DATE('2026-10-21','YYYY-MM-DD'), '12:39', 814.32, 65.15, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (45, 23, 1, TO_DATE('2026-10-21','YYYY-MM-DD'), '12:47', 814.32, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (46, 25, 3, TO_DATE('2026-10-21','YYYY-MM-DD'), '15:00', 2204.0, 0, 'Refunded');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (47, 26, 5, TO_DATE('2026-10-22','YYYY-MM-DD'), '22:08', 1044.0, 52.2, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (48, 26, 1, TO_DATE('2026-10-22','YYYY-MM-DD'), '22:17', 1044.0, 104.4, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (49, 27, 1, TO_DATE('2026-10-24','YYYY-MM-DD'), '16:00', 5660.8, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (50, 28, 3, TO_DATE('2026-10-24','YYYY-MM-DD'), '19:56', 6554.0, 524.32, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (51, 29, 1, TO_DATE('2026-10-25','YYYY-MM-DD'), '15:12', 348.0, 17.4, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (52, 30, 5, TO_DATE('2026-10-26','YYYY-MM-DD'), '12:48', 777.2, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (53, 30, 4, TO_DATE('2026-10-26','YYYY-MM-DD'), '13:26', 777.2, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (54, 31, 5, TO_DATE('2026-10-27','YYYY-MM-DD'), '18:20', 962.8, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (55, 31, 3, TO_DATE('2026-10-27','YYYY-MM-DD'), '19:00', 962.8, 48.14, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (56, 32, 2, TO_DATE('2026-10-29','YYYY-MM-DD'), '16:57', 518.13, 51.81, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (57, 33, 1, TO_DATE('2026-10-29','YYYY-MM-DD'), '17:08', 630.27, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (58, 32, 6, TO_DATE('2026-10-29','YYYY-MM-DD'), '17:12', 518.14, 25.91, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (59, 33, 1, TO_DATE('2026-10-29','YYYY-MM-DD'), '17:13', 630.26, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (60, 32, 4, TO_DATE('2026-10-29','YYYY-MM-DD'), '17:27', 518.13, 25.91, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (61, 33, 4, TO_DATE('2026-10-29','YYYY-MM-DD'), '17:42', 630.27, 31.51, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (62, 34, 5, TO_DATE('2026-10-31','YYYY-MM-DD'), '18:47', 794.2, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (63, 34, 4, TO_DATE('2026-10-31','YYYY-MM-DD'), '19:39', 794.2, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (64, 35, 4, TO_DATE('2026-11-01','YYYY-MM-DD'), '14:44', 0, 0, 'Failed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (65, 35, 5, TO_DATE('2026-11-01','YYYY-MM-DD'), '14:49', 2621.6, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (66, 36, 1, TO_DATE('2026-11-02','YYYY-MM-DD'), '16:03', 6061.0, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (67, 37, 4, TO_DATE('2026-11-03','YYYY-MM-DD'), '18:18', 1032.4, 103.24, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (68, 38, 6, TO_DATE('2026-11-03','YYYY-MM-DD'), '19:08', 734.67, 73.47, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (69, 38, 4, TO_DATE('2026-11-03','YYYY-MM-DD'), '19:33', 734.67, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (70, 38, 2, TO_DATE('2026-11-03','YYYY-MM-DD'), '19:49', 734.66, 58.77, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (71, 39, 4, TO_DATE('2026-11-04','YYYY-MM-DD'), '21:15', 2888.4, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (72, 40, 2, TO_DATE('2026-11-05','YYYY-MM-DD'), '12:39', 290.0, 23.2, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (73, 41, 2, TO_DATE('2026-11-07','YYYY-MM-DD'), '17:33', 3074.0, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (74, 42, 4, TO_DATE('2026-11-07','YYYY-MM-DD'), '18:43', 928.0, 92.8, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (75, 43, 6, TO_DATE('2026-11-09','YYYY-MM-DD'), '13:55', 290.0, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (76, 44, 1, TO_DATE('2026-11-10','YYYY-MM-DD'), '17:10', 440.0, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (77, 46, 6, TO_DATE('2026-11-12','YYYY-MM-DD'), '15:48', 1728.4, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (78, 47, 2, TO_DATE('2026-11-14','YYYY-MM-DD'), '16:22', 1611.6, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (79, 48, 4, TO_DATE('2026-11-15','YYYY-MM-DD'), '19:48', 4121.48, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (80, 49, 2, TO_DATE('2026-11-15','YYYY-MM-DD'), '19:49', 0, 0, 'Failed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (81, 49, 4, TO_DATE('2026-11-15','YYYY-MM-DD'), '20:36', 2088.0, 104.4, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (82, 50, 2, TO_DATE('2026-11-16','YYYY-MM-DD'), '20:37', 3572.8, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (83, 51, 4, TO_DATE('2026-11-17','YYYY-MM-DD'), '12:39', 938.8, 0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (84, 52, 1, TO_DATE('2026-11-17','YYYY-MM-DD'), '18:10', 1170.8, 0, 'Refunded');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (85, 57, 5, TO_DATE('2026-11-18','YYYY-MM-DD'), '20:35', 1241.2, 124.12, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (86, 58, 3, TO_DATE('2026-11-18','YYYY-MM-DD'), '20:45', 1653.0, 132.24, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (87, 59, 6, TO_DATE('2026-11-18','YYYY-MM-DD'), '21:05', 348.0, 0.0, 'Completed');
INSERT INTO PAYMENT (Payment_ID, Order_ID, PaymentMethod_ID, PaymentDate, PaymentTime, AmountPaid, TipAmount, TransactionStatus) VALUES (88, 60, 2, TO_DATE('2026-11-18','YYYY-MM-DD'), '21:40', 652.5, 52.2, 'Completed');

-- BILL_SPLIT (57 rows)
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (1, 5, 1, 174.0, 1, 7);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (2, 5, 2, 174.0, 1, 8);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (3, 5, 3, 174.0, 1, 6);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (4, 6, 1, 38.67, 1, 10);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (5, 6, 2, 38.67, 1, 9);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (6, 6, 3, 38.66, 1, 11);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (7, 7, 1, 226.2, 1, 14);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (8, 7, 2, 226.2, 1, 12);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (9, 7, 3, 226.2, 1, 13);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (10, 8, 1, 815.48, 1, 15);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (11, 8, 2, 815.48, 1, 16);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (12, 12, 1, 989.87, 1, 20);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (13, 12, 2, 989.87, 1, 22);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (14, 12, 3, 989.86, 1, 21);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (15, 15, 1, 928.0, 1, 25);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (16, 15, 2, 928.0, 1, 24);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (17, 15, 3, 928.0, 1, 26);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (18, 16, 1, 34.8, 1, 29);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (19, 16, 2, 34.8, 1, 27);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (20, 16, 3, 34.8, 1, 28);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (21, 17, 1, 746.27, 1, 30);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (22, 17, 2, 746.27, 1, 32);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (23, 17, 3, 746.26, 1, 31);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (24, 19, 1, 378.93, 1, 34);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (25, 19, 2, 378.93, 1, 36);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (26, 19, 3, 378.94, 1, 35);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (27, 22, 1, 415.4, 1, 40);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (28, 22, 2, 415.4, 1, 42);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (29, 22, 3, 415.4, 1, 41);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (30, 23, 1, 814.32, 1, 43);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (31, 23, 2, 814.32, 1, 45);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (32, 23, 3, 814.32, 1, 44);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (33, 26, 1, 1044.0, 1, 47);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (34, 26, 2, 1044.0, 1, 48);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (35, 30, 1, 777.2, 1, 52);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (36, 30, 2, 777.2, 1, 53);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (37, 31, 1, 962.8, 1, 54);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (38, 31, 2, 962.8, 1, 55);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (39, 32, 1, 518.13, 1, 56);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (40, 32, 2, 518.13, 1, 60);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (41, 32, 3, 518.14, 1, 58);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (42, 33, 1, 630.27, 1, 61);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (43, 33, 2, 630.27, 1, 57);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (44, 33, 3, 630.26, 1, 59);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (45, 34, 1, 794.2, 1, 62);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (46, 34, 2, 794.2, 1, 63);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (47, 38, 1, 734.67, 1, 68);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (48, 38, 2, 734.67, 1, 69);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (49, 38, 3, 734.66, 1, 70);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (50, 57, 1, 1241.2, 1, 85);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (51, 57, 2, 1241.2, 0, NULL);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (52, 58, 1, 1653.0, 1, 86);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (53, 58, 2, 1653.0, 0, NULL);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (54, 59, 1, 348.0, 1, 87);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (55, 59, 2, 348.0, 0, NULL);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (56, 60, 1, 652.5, 1, 88);
INSERT INTO BILL_SPLIT (BillSplit_ID, Order_ID, SplitNumber, Amount, IsPaid, Payment_ID) VALUES (57, 60, 2, 652.5, 0, NULL);