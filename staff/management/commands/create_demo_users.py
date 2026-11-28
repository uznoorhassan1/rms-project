import os

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from django.db.utils import DatabaseError

from core.models import Customer, Employee


class Command(BaseCommand):
    help = "Create a login for every employee/customer in the database (needs DEMO_PASSWORD)."

    def handle(self, *args, **options):
        password = os.environ.get("DEMO_PASSWORD")
        if not password:
            self.stdout.write("DEMO_PASSWORD not set: skipping demo accounts.")
            return
        made = 0
        try:
            people = list(Employee.objects.all()) + list(Customer.objects.all())
        except DatabaseError:
            self.stdout.write("Restaurant tables not found yet (load the SQL file first): skipping.")
            return
        for p in people:
            if p.email and not User.objects.filter(username=p.email).exists():
                User.objects.create_user(p.email, p.email, password, first_name=p.firstname, last_name=p.lastname)
                made += 1
        self.stdout.write(f"{made} accounts created.")
