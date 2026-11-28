import json, os, urllib.request
from datetime import date
from django import forms
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.views import LoginView
from django.db import transaction
from django.db.models import Max
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.views.decorators.http import require_POST
from core.models import Customer, Employee, EmployeeRole
from .roles import get_role, role_required


class EmailLoginForm(AuthenticationForm):
    username = forms.EmailField(label="Email")  # rejects text that is not an email


class RoleLoginView(LoginView):
    template_name = "login.html"
    authentication_form = EmailLoginForm
    redirect_authenticated_user = True


def _email_free(email):
    email = email.lower()
    if User.objects.filter(username__iexact=email).exists() or \
       Customer.objects.filter(email__iexact=email).exists() or \
       Employee.objects.filter(email__iexact=email).exists():
        raise forms.ValidationError("This email is already registered.")
    return email


def _passwords_ok(data):
    if data.get("password") != data.get("password2"):
        raise forms.ValidationError("Passwords do not match.")
    validate_password(data["password"])


class SignupForm(forms.Form):
    first_name = forms.CharField(max_length=30)
    last_name = forms.CharField(max_length=30)
    phone = forms.CharField(max_length=15, required=False)
    email = forms.EmailField(max_length=60)
    dob = forms.DateField(required=False, widget=forms.DateInput(attrs={"type": "date"}))
    dietary = forms.CharField(max_length=30, required=False, label="Dietary preference")
    password = forms.CharField(widget=forms.PasswordInput)
    password2 = forms.CharField(widget=forms.PasswordInput, label="Confirm password")

    def clean_email(self):
        return _email_free(self.cleaned_data["email"])

    def clean(self):
        d = super().clean()
        if d.get("password"):
            _passwords_ok(d)
        return d


def signup(request):
    """Public sign-up: creates a login AND a new row in CUSTOMER."""
    f = SignupForm(request.POST or None)
    if request.method == "POST" and f.is_valid():
        d = f.cleaned_data
        with transaction.atomic():
            nid = (Customer.objects.aggregate(m=Max("customer_id"))["m"] or 0) + 1
            Customer.objects.create(customer_id=nid, firstname=d["first_name"], lastname=d["last_name"],
                                    phone=d["phone"] or None, email=d["email"], registrationdate=date.today(),
                                    dob=d["dob"], dietary_preference=d["dietary"] or "None", isvip=0)
            user = User.objects.create_user(d["email"], d["email"], d["password"],
                                            first_name=d["first_name"], last_name=d["last_name"])
        login(request, user)
        return redirect("home")
    return render(request, "signup.html", {"form": f})


class EmployeeForm(forms.Form):
    first_name = forms.CharField(max_length=30)
    last_name = forms.CharField(max_length=30)
    phone = forms.CharField(max_length=15, required=False)
    email = forms.EmailField(max_length=60)
    role = forms.ModelChoiceField(EmployeeRole.objects.all(), label="Role")
    hourly_rate = forms.DecimalField(max_digits=8, decimal_places=2, min_value=0)
    password = forms.CharField(widget=forms.PasswordInput, label="Temporary password")
    password2 = forms.CharField(widget=forms.PasswordInput, label="Confirm password")

    def clean_email(self):
        return _email_free(self.cleaned_data["email"])

    def clean(self):
        d = super().clean()
        if d.get("password"):
            _passwords_ok(d)
        return d


@role_required("manager")
def add_employee(request):
    """Only a manager can hire: creates a login AND a new row in EMPLOYEE."""
    f = EmployeeForm(request.POST or None)
    done = None
    if request.method == "POST" and f.is_valid():
        d = f.cleaned_data
        with transaction.atomic():
            nid = (Employee.objects.aggregate(m=Max("employee_id"))["m"] or 0) + 1
            Employee.objects.create(employee_id=nid, role=d["role"], firstname=d["first_name"],
                                    lastname=d["last_name"], phone=d["phone"] or None, email=d["email"],
                                    hiredate=date.today(), hourlyrate=d["hourly_rate"], isactive=1)
            User.objects.create_user(d["email"], d["email"], d["password"],
                                     first_name=d["first_name"], last_name=d["last_name"])
        done = d["email"]
        f = EmployeeForm()
    return render(request, "add_employee.html", {"form": f, "done": done})


@login_required
def home(request):
    return render(request, "home.html", {"role": get_role(request.user)})


@login_required
@require_POST
def assistant(request):
    """AI assistant. The Gemini key stays on the server (in .env), never in the browser."""
    q = json.loads(request.body or "{}").get("q", "").strip()[:500]
    key = os.environ.get("GEMINI_API_KEY")
    if not q or not key:
        return JsonResponse({"answer": "The assistant is not configured yet."})
    model = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")
    body = {"systemInstruction": {"parts": [{"text": "You are a helpful assistant inside a restaurant management "
            f"system. The user is a {get_role(request.user)}. Answer briefly about using the system."}]},
            "contents": [{"parts": [{"text": q}]}]}
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
        json.dumps(body).encode(), {"Content-Type": "application/json", "x-goog-api-key": key})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            answer = json.load(r)["candidates"][0]["content"]["parts"][0]["text"]
    except Exception:
        answer = "Sorry, the assistant could not answer right now."
    return JsonResponse({"answer": answer})