from django.conf import settings
from django.db import models


class EmployeeRole(models.Model):
    role_name = models.CharField(max_length=100, unique=True)
    role_description = models.CharField(max_length=500, blank=True)
    access_level = models.PositiveSmallIntegerField(default=1)

    def __str__(self):
        return self.role_name


class Employee(models.Model):
    # Optional link to a Django login account
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL,
    )
    role = models.ForeignKey(
        EmployeeRole, on_delete=models.PROTECT, related_name="employees"
    )
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    hire_date = models.DateField()
    hourly_rate = models.DecimalField(max_digits=8, decimal_places=2)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"


class ShiftSchedule(models.Model):
    SHIFT_TYPES = [
        ("Morning", "Morning"),
        ("Evening", "Evening"),
        ("Night", "Night"),
    ]

    employee = models.ForeignKey(
        Employee, on_delete=models.CASCADE, related_name="shifts"
    )
    shift_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    shift_type = models.CharField(max_length=20, choices=SHIFT_TYPES)

    def __str__(self):
        return f"{self.employee} - {self.shift_date} ({self.shift_type})"