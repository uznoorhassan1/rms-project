from django.contrib import admin
from django.contrib.auth.views import LogoutView
from django.urls import include, path
from staff import views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("login/", views.RoleLoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("signup/", views.signup, name="signup"),
    path("add-employee/", views.add_employee, name="add_employee"),
    path("assistant/", views.assistant, name="assistant"),
    # One line per module. Each owner only edits their own app's urls.py, never this file.
    path("reservations/", include("floor.urls")),    # Member 2
    path("menu/", include("menu.urls")),             # Member 3
    path("orders/", include("orders.urls")),         # Member 3
    path("billing/", include("billing.urls")),       # Member 4
    path("inventory/", include("inventory.urls")),   # Member 4
    path("", views.home, name="home"),
]
