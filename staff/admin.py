from django.contrib import admin
from .models import EmployeeRole, Employee, ShiftSchedule


@admin.register(EmployeeRole)
class EmployeeRoleAdmin(admin.ModelAdmin):
    list_display = ("role_name", "access_level")


@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ("first_name", "last_name", "role", "hire_date", "is_active")
    list_filter = ("role", "is_active")


@admin.register(ShiftSchedule)
class ShiftScheduleAdmin(admin.ModelAdmin):
    list_display = ("employee", "shift_date", "shift_type", "start_time", "end_time")
    list_filter = ("shift_type", "shift_date")