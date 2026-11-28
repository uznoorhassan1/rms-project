# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class BillSplit(models.Model):
    billsplit_id = models.IntegerField(primary_key=True)
    order = models.ForeignKey('Orders', models.DO_NOTHING)
    splitnumber = models.IntegerField()
    amount = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    ispaid = models.IntegerField()
    payment = models.ForeignKey('Payment', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'bill_split'


class Category(models.Model):
    category_id = models.IntegerField(primary_key=True)
    categoryname = models.CharField(max_length=40)
    displayorder = models.IntegerField(blank=True, null=True)
    isactive = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'category'


class Customer(models.Model):
    customer_id = models.IntegerField(primary_key=True)
    firstname = models.CharField(max_length=30)
    lastname = models.CharField(max_length=30)
    phone = models.CharField(max_length=15, blank=True, null=True)
    email = models.CharField(unique=True, max_length=60, blank=True, null=True)
    registrationdate = models.DateField(blank=True, null=True)
    dob = models.DateField(blank=True, null=True)
    dietary_preference = models.CharField(max_length=30, blank=True, null=True)
    isvip = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'customer'


class Employee(models.Model):
    employee_id = models.IntegerField(primary_key=True)
    role = models.ForeignKey('EmployeeRole', models.DO_NOTHING)
    firstname = models.CharField(max_length=30)
    lastname = models.CharField(max_length=30)
    phone = models.CharField(max_length=15, blank=True, null=True)
    email = models.CharField(unique=True, max_length=60, blank=True, null=True)
    hiredate = models.DateField(blank=True, null=True)
    hourlyrate = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    isactive = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'employee'


class EmployeeRole(models.Model):
    role_id = models.IntegerField(primary_key=True)
    rolename = models.CharField(max_length=30)
    roledescription = models.CharField(max_length=150, blank=True, null=True)
    accesslevel = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'employee_role'


class InventoryItem(models.Model):
    inventoryitem_id = models.IntegerField(primary_key=True)
    itemname = models.CharField(max_length=40)
    quantityinstock = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    unitofmeasure = models.CharField(max_length=15, blank=True, null=True)
    reorderthreshold = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    costperunit = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    lastrestockdate = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'inventory_item'


class MenuDiscount(models.Model):
    discount_id = models.IntegerField(primary_key=True)
    menuitem = models.ForeignKey('MenuItem', models.DO_NOTHING)
    discountname = models.CharField(max_length=40, blank=True, null=True)
    percentage = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    startdate = models.DateField(blank=True, null=True)
    enddate = models.DateField(blank=True, null=True)
    isactive = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'menu_discount'


class MenuItem(models.Model):
    menuitem_id = models.IntegerField(primary_key=True)
    category = models.ForeignKey(Category, models.DO_NOTHING)
    name = models.CharField(max_length=60)
    description = models.CharField(max_length=200, blank=True, null=True)
    unitprice = models.DecimalField(max_digits=8, decimal_places=2)
    preparationtime = models.IntegerField(blank=True, null=True)
    calories = models.IntegerField(blank=True, null=True)
    isavailable = models.IntegerField()
    isspicy = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'menu_item'


class OrderDetail(models.Model):
    orderdetail_id = models.IntegerField(primary_key=True)
    order = models.ForeignKey('Orders', models.DO_NOTHING)
    menuitem = models.ForeignKey(MenuItem, models.DO_NOTHING)
    quantity = models.IntegerField()
    unitprice = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    subtotalprice = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    specialinstructions = models.CharField(max_length=150, blank=True, null=True)
    itemstatus = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'order_detail'


class OrderType(models.Model):
    ordertype_id = models.IntegerField(primary_key=True)
    typename = models.CharField(max_length=30)
    deliveryfee = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'order_type'


class Orders(models.Model):
    order_id = models.IntegerField(primary_key=True)
    table = models.ForeignKey('RestaurantTable', models.DO_NOTHING, blank=True, null=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING, blank=True, null=True)
    customer = models.ForeignKey(Customer, models.DO_NOTHING, blank=True, null=True)
    ordertype = models.ForeignKey(OrderType, models.DO_NOTHING)
    orderdate = models.DateField()
    ordertime = models.CharField(max_length=5, blank=True, null=True)
    orderstatus = models.CharField(max_length=15, blank=True, null=True)
    totalamount = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    taxamount = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    discountamount = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'orders'


class Payment(models.Model):
    payment_id = models.IntegerField(primary_key=True)
    order = models.ForeignKey(Orders, models.DO_NOTHING)
    paymentmethod = models.ForeignKey('PaymentMethod', models.DO_NOTHING)
    paymentdate = models.DateField(blank=True, null=True)
    paymenttime = models.CharField(max_length=5, blank=True, null=True)
    amountpaid = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    tipamount = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    transactionstatus = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'payment'


class PaymentMethod(models.Model):
    paymentmethod_id = models.IntegerField(primary_key=True)
    methodname = models.CharField(max_length=30)
    processingfeerate = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'payment_method'


class PurchaseOrder(models.Model):
    purchaseorder_id = models.IntegerField(primary_key=True)
    supplier = models.ForeignKey('Supplier', models.DO_NOTHING)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    orderdate = models.DateField(blank=True, null=True)
    expecteddelivery = models.DateField(blank=True, null=True)
    totalcost = models.DecimalField(max_digits=12, decimal_places=2, blank=True, null=True)
    status = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'purchase_order'


class PurchaseOrderDetail(models.Model):
    podetail_id = models.IntegerField(primary_key=True)
    purchaseorder = models.ForeignKey(PurchaseOrder, models.DO_NOTHING)
    inventoryitem = models.ForeignKey(InventoryItem, models.DO_NOTHING)
    quantityordered = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)
    unitprice = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'purchase_order_detail'


class RecipeIngredient(models.Model):
    recipe_id = models.IntegerField(primary_key=True)
    menuitem = models.ForeignKey(MenuItem, models.DO_NOTHING)
    inventoryitem = models.ForeignKey(InventoryItem, models.DO_NOTHING)
    quantityrequired = models.DecimalField(max_digits=8, decimal_places=3, blank=True, null=True)
    unitofmeasure = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'recipe_ingredient'


class Reservation(models.Model):
    reservation_id = models.IntegerField(primary_key=True)
    customer = models.ForeignKey(Customer, models.DO_NOTHING)
    table = models.ForeignKey('RestaurantTable', models.DO_NOTHING)
    reservationdate = models.DateField()
    reservationtime = models.CharField(max_length=5)
    numberofpeople = models.IntegerField()
    specialrequests = models.CharField(max_length=200, blank=True, null=True)
    status = models.CharField(max_length=15, blank=True, null=True)
    createdat = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reservation'


class RestaurantTable(models.Model):
    table_id = models.IntegerField(primary_key=True)
    tablenumber = models.IntegerField(unique=True)
    capacity = models.IntegerField()
    section = models.ForeignKey('TableSection', models.DO_NOTHING, blank=True, null=True)
    status = models.CharField(max_length=20, blank=True, null=True)
    smokingallowed = models.IntegerField(blank=True, null=True)
    shape = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'restaurant_table'


class ShiftSchedule(models.Model):
    shift_id = models.IntegerField(primary_key=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    shiftdate = models.DateField(blank=True, null=True)
    starttime = models.CharField(max_length=5, blank=True, null=True)
    endtime = models.CharField(max_length=5, blank=True, null=True)
    shifttype = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shift_schedule'


class Supplier(models.Model):
    supplier_id = models.IntegerField(primary_key=True)
    companyname = models.CharField(max_length=60)
    contactperson = models.CharField(max_length=60, blank=True, null=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    email = models.CharField(max_length=60, blank=True, null=True)
    city = models.CharField(max_length=30, blank=True, null=True)
    state = models.CharField(max_length=30, blank=True, null=True)
    zip = models.CharField(max_length=10, blank=True, null=True)
    street = models.CharField(max_length=80, blank=True, null=True)
    paymentterms = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supplier'


class TableSection(models.Model):
    section_id = models.IntegerField(primary_key=True)
    sectionname = models.CharField(max_length=40)
    floornumber = models.IntegerField(blank=True, null=True)
    description = models.CharField(max_length=200, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'table_section'
