1️⃣ Verify the Printer Is Shared

On your print server (ex: DC-01 or SRV-PRINT01):

Open Print Management

Go to:

Print Servers → <ServerName> → Printers

Right-click the printer → Properties

Go to Sharing

Check:

Share this printer

Example share path:

\\DC-01\LabPrinter
2️⃣ Allow Domain Users Permission

Still in Printer Properties:

Go to Security

Make sure this group exists:

Domain Users

Give them:

Print

permissions.

This allows domain users to connect and print.

3️⃣ Open Group Policy Management

On your domain controller:

Open Group Policy Management (gpmc.msc)

Expand:

Forest
 → Domains
 → yourdomain.local

Right-click Group Policy Objects

New

Name it something like:

Deploy Printer
4️⃣ Edit the GPO

Right-click the new GPO → Edit

Go to:

User Configuration
 → Preferences
 → Control Panel Settings
 → Printers

Right-click → New → Shared Printer

5️⃣ Configure the Printer Deployment

Set:

Action: Create

Share Path:

\\DC-01\LabPrinter

You can also check:

Set this printer as the default printer
6️⃣ Link the GPO to Users

Back in Group Policy Management:

Right-click your Users OU (or domain if lab):

Link Existing GPO

Select:

Deploy Printer
7️⃣ Update Group Policy on Client

On the domain-joined client run:

gpupdate /force

Or reboot.

8️⃣ Verify Printer Appears

On the client machine:

Settings → Printers & Scanners

You should see:

LabPrinter on DC-01
Example Lab Setup
DC-01 (Domain Controller + Print Server)
│
├─ Shared Printer
│   \\DC-01\LabPrinter
│
└─ GPO
    Deploy Printer

Client:

WIN11-CLIENT01

User logs in → printer automatically appears.
