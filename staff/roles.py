from functools import wraps
from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from core.models import Customer, Employee

# Maps the 8 roles in the EMPLOYEE_ROLE table to the 4 screens of the UI.
GROUPS = {"manager": "manager", "head chef": "chef", "chef": "chef", "kitchen helper": "chef",
          "waiter": "waiter", "host": "waiter", "bartender": "waiter", "cashier": "waiter"}


def get_role(user):
    """'manager' | 'chef' | 'waiter' | 'customer' | None, decided by the user's email."""
    if not user.is_authenticated:
        return None
    emp = Employee.objects.filter(email__iexact=user.email, isactive=1).select_related("role").first()
    if emp:
        return GROUPS.get(emp.role.rolename.lower())
    if user.is_superuser:
        return "manager"
    if Customer.objects.filter(email__iexact=user.email).exists():
        return "customer"
    return None


def role_required(*roles):
    """Put above a view:  @role_required('waiter', 'manager')"""
    def deco(view):
        @login_required
        @wraps(view)
        def wrapper(request, *a, **kw):
            if get_role(request.user) not in roles:
                raise PermissionDenied
            return view(request, *a, **kw)
        return wrapper
    return deco