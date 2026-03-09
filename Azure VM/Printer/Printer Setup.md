If you're building an AD lab, you can absolutely install Print and Document Services even if the printer is fictional. You do not need DHCP, and you don’t even need a real printer device. 👍

Easiest Way: Create a Fake Printer Using a TCP/IP Port

Install the Print Server role:

Install-WindowsFeature Print-Server -IncludeManagementTools

Open Print Management
Server Manager → Tools → Print Management

Go to:
Print Servers → YourServer → Printers

Click Add Printer

Choose:
Add a new printer using an existing port or Create a new port

Select Standard TCP/IP Port

Enter a fake IP address, for example:

10.10.10.50

When it asks for a driver, choose something generic like:

Generic / Text Only

Microsoft XPS Document Writer

HP Universal Printing PCL

Name it something like:

Lab-Printer01

Share the printer so it shows up in AD.
