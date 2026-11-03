"""Builds invented demo fixtures. Fixed seed -> identical graph every run.
Usage: python3 data/gen_demo.py
"""
import random
import shutil
from pathlib import Path

random.seed(1337)
OUT = Path(__file__).parent / "demo"
if OUT.exists():
    shutil.rmtree(OUT)

clients = ["Northwind Coffee", "Alder & Finch", "Kiln Studio", "Harbour Outdoors", "Pepper Lane Foods", "Mossgrove Books"]
people = ["Maya Ortiz", "Tom Brandt", "Priya Nair", "Sam Whitlock", "Elise Moreau", "Jonas Held"]
tools = ["Shopify", "Klaviyo", "Stripe", "Figma", "Xero"]
topics = ["Pricing", "Retainer Terms", "Launch Checklist", "Margin Model", "Onboarding Flow"]

def w(folder, title, body, typ):
    d = OUT / folder
    d.mkdir(parents=True, exist_ok=True)
    (d / (title.replace("&", "and") + ".md")).write_text(f"---\ntype: {typ}\n---\n# {title}\n\n{body}\n")

for c in clients:
    p = random.choice(people)
    price = random.choice([4200, 5800, 7500, 9000])
    ret = random.choice([800, 950, 1200])
    t = random.sample(tools, 2)
    w("Clients", c, f"Contact: [[{p}]]. Build £{price}, retainer £{ret}/mo. Stack: [[{t[0]}]], [[{t[1]}]]. See [[{c} Build]].", "client")
    w("Projects", f"{c} Build", f"Store build for [[{c}]]. Follows [[Launch Checklist]]. Margin per [[Margin Model]].", "project")
    for i in range(1, random.randint(2, 3)):
        paid = random.choice(["paid", "half-paid, job still running"])
        w("Invoices", f"INV-{c[:3].upper()}-{i}", f"Client [[{c}]]. Status: {paid}.", "invoice")
    w("Meetings", f"{c} Kickoff", f"Attendees: [[{p}]]. Agreed scope in [[{c} Build]]. Pricing discussed: [[Pricing]].", "meeting")
for p in people:
    w("People", p, f"Works with [[{random.choice(clients)}]].", "person")
for t in tools:
    w("Tools", t, f"Used across client builds. Pricing notes in [[Margin Model]].", "tool")
for t in topics:
    w("Notes", t, f"Reference for [[{random.choice(clients)}]] and [[{random.choice(tools)}]]. Related: [[{random.choice(topics)}]].", "note")
print(f"demo written to {OUT}")
