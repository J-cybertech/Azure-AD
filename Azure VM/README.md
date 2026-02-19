Step 1 — Create the Windows Server VM in Azure(https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account)

In this step, you will create a low-cost Windows Server virtual machine in Azure. Most settings can be left at their defaults — only the critical ones are called out explicitly.

Cost Expectation
VM size: B2s
Estimated cost: ~$25–40/month
Stop/deallocate the VM when not in use to reduce cost (extremely cheap if deleted)
1. Create the Virtual Machine
Log into the Azure Portal
Navigate to Virtual Machines
Select Create → Azure virtual machine
2. Basics Tab (Important)
Subscription: Leave default
Resource Group: Create a new one (e.g. ad-lab-rg)
Virtual Machine Name: DC01
Region: Closest region to you
Availability Options: Leave default
Image: Windows Server 2022 Datacenter
Size: B2s or similar
3. Administrator Account
Username: Any name
Password: Strong password — save this
This local administrator account will later become your first domain administrator.

4. Inbound Port Rules
Public inbound ports: Allow selected ports
Inbound ports: RDP (3389)
5. Disks Tab
OS disk type: Standard SSD
Leave all other settings at their defaults
6. Networking Tab (Do Not Skip)
Virtual network: Create new
Subnet: Default
Public IP: Create new
NIC network security group: Basic
Inbound ports: RDP (3389)
Why this matters
Your Domain Controller and future client VM must be on the same virtual network. Fixing this later causes DNS and authentication issues.

7. Management, Monitoring, Advanced, Tags
Leave all settings at their defaults
8. Review + Create
Review your settings
Select Create
Wait for deployment to complete
9. Set a Static Private IP (Recommended)
Open the VM → Networking
Select the Network Interface (NIC)
Go to IP configurations
Change Private IP assignment from Dynamic to Static
Save your changes
This prevents IP changes that can break DNS and Active Directory later.

##Checkpoint
VM deployed successfully
You can RDP into DC01
Windows Server desktop loads
Private IP is set to Static
If any of these fail, stop and fix the issue before moving on.

----------------------------------------------------
Step 2 — Install Active Directory Domain Services
In this step, you will install the Active Directory Domain Services (AD DS) role. You are not creating a domain yet — that happens in the next step.

What’s happening in this step
You are installing the AD DS binaries and management tools. No domain, forest, DNS configuration, or authentication changes occur yet.

1. Connect to the Server
Use Remote Desktop (RDP) to connect to the server
Log in with the local administrator account you created earlier
2. Open Server Manager
Server Manager should open automatically after login
If not, open it from the Start Menu
3. Add Roles and Features
Select Add Roles and Features
On the Before you begin screen, select Next
Select Role-based or feature-based installation
Select the local server (default)
4. Server Roles
Check Active Directory Domain Services
When prompted, select Add Features
No additional roles are required at this stage.

5. Features
Leave all features at their default selections
6. AD DS Information
Review the information page
Select Next
7. Confirmation
Confirm the role selection
Select Install
Wait for the installation to complete. The server does not need to reboot yet.

8. Important Notes
Do not click Promote this server to a domain controller yet
Do not create a domain or forest in this step
No domain name or DSRM password is set here
You will promote the server and create the domain in the next step.

##Checkpoint
AD DS role shows as installed in Server Manager
No domain has been created yet
Server Manager shows a notification to Promote this server to a domain controller
If you see the promotion option, you’re ready for the next step.


----------------------------------------------------------------------
Step 3 — Promote the Server to a Domain Controller
In this step, you will promote the server to a domain controller and create your first Active Directory domain.

This is the point where Active Directory actually becomes active.

1. Start the Promotion Wizard
Open Server Manager
Select the notification flag at the top of the window
Click Promote this server to a domain controller
2. Deployment Configuration
You are creating a brand-new Active Directory environment.

Select Add a new forest
Root domain name: Choose a private internal domain
Example: lab.local
This lab uses a private internal domain. In real environments, domain naming requires more planning — we’ll keep it simple here.

3. Domain Controller Options
Forest functional level: Leave default
Domain functional level: Leave default
DNS server: Checked (default)
Global Catalog (GC): Checked (default)
Directory Services Restore Mode (DSRM)
Set a DSRM password and save it. This password is required for recovery scenarios when Active Directory cannot start normally.

You will almost never use this password day-to-day, but it is critical for disaster recovery.

4. DNS Options
You may see a warning about DNS delegation
This is expected in a lab environment
Select Next
5. Additional Options
NetBIOS domain name: Accept the default
6. Paths
Leave database, log files, and SYSVOL paths at their defaults
7. Review Options
Review the configuration summary
Select Next
8. Prerequisites Check
Allow all prerequisite checks to complete
Warnings are acceptable in a lab
Select Install
9. Reboot and Log In
The server will automatically reboot after promotion completes.

After reboot, log in using your domain administrator account (for example: LAB\Administrator).

##Checkpoint
Server successfully rebooted after promotion
You can log in using a domain account
Server Manager shows this server as a Domain Controller
DNS and Active Directory tools are available
If all of these are true, your domain is live and ready for clients.


-----------------------------------------------

Step 4 — Create Organizational Units
In this step, you will create a realistic Organizational Unit (OU) structure based on branch location.

This mirrors how Active Directory is commonly structured in production environments, especially in banks and multi-site organizations.

How OUs are used in the real world
In production, OUs are designed around policy and delegation boundaries — not just object type. Location-based OUs make it easier to apply Group Policy, troubleshoot issues, and delegate access.

1. Open Active Directory Users and Computers
Log into the domain controller
Open the Start Menu
Search for and open Active Directory Users and Computers
2. Locate the Domain Root
In the left pane, expand your domain (e.g., lab.local)
This top-level container is the domain root
You will create a top-level OU to represent organizational structure, rather than placing objects directly at the root.

3. Create the _Branches OU
Right-click the domain root
Select New → Organizational Unit
Name the OU _Branches
Ensure Protect container from accidental deletion is checked
Select OK
4. Create a Branch OU
You will now create an OU for a specific branch. In a real environment, each physical location would have its own OU.

Right-click the _Branches OU
Select New → Organizational Unit
Name the OU after a branch (e.g., Houston)
Ensure Protect container from accidental deletion is checked
Select OK
5. Create Sub-OUs for the Branch
Within each branch, separate users and devices to allow targeted policy and easier troubleshooting.

Right-click the branch OU (e.g., Houston)
Select New → Organizational Unit
Name the OU Users
Repeat to create Workstations and Laptops
Ensure accidental deletion protection is enabled on each OU
6. Verify the OU Structure
Confirm the OUs exist and are nested correctly
Your structure should look similar to this:
_Branches
 └── Houston
     ├── Users
     ├── Workstations
     └── Laptops
Why Not _Users or _Computers?
In small labs, you may see flat OUs like _Users or_Computers. In production environments, OUs are almost always organized around policy boundaries such as branch location.

This approach scales better and reflects how Active Directory is managed in real organizations.

Important Notes
Avoid placing users or computers in default containers
Group Policy is applied at the OU level, not containers
This structure will be used heavily in upcoming steps
##Checkpoint
_Branches OU exists at the domain root
A branch OU (e.g., Houston) exists
Users, Workstations, and Laptops sub-OUs exist
Accidental deletion protection is enabled
If this looks correct, you’re ready to start creating users and joining machines to the domain.

---------------------------------------------------
Step 5 — Create Users
In this step, you will create domain user accounts and place them into the appropriate branch-based Users OU.

Creating and managing users is one of the most common Active Directory tasks performed by IT administrators.

Where users live in production
In real environments, users are typically placed into OUs based on location or department, not into a single flat Users OU. This allows Group Policy and delegation to be applied cleanly.

1. Open Active Directory Users and Computers
Log into the domain controller
Open Active Directory Users and Computers
Expand your domain (e.g., lab.local)
Navigate to _Branches → Houston → Users
2. Create the First User (Alice Johnson)
Right-click the Users OU
Select New → User
First name: Alice
Last name: Johnson
User logon name: ajohnson
Select Next
3. Set the User Password
Set an initial password
Uncheck User must change password at next logon (for this lab)
Ensure User cannot change password is unchecked
Ensure Password never expires is unchecked
Select Next, then Finish
In real environments, password behavior is enforced with Group Policy, not manual user settings.

4. Create Additional Users
Repeat the same process to create the following users in the Houston → Users OU:

Bob Martinez — bmartinez
Chris Walker — cwalker
5. Verify User Creation
Confirm all users appear in _Branches → Houston → Users
Double-click a user to view account properties
Verify the Distinguished Name reflects the correct OU path
PowerShell Equivalent (Optional)
The same users can be created using PowerShell. This is common for automation and bulk user provisioning.

==``
$ou = "OU=Users,OU=Houston,OU=_Branches,DC=lab,DC=local"

New-ADUser -Name "Alice Johnson" -GivenName Alice -Surname Johnson -SamAccountName ajohnson -Path $ou -AccountPassword (Read-Host -AsSecureString) -Enabled $true

New-ADUser -Name "Bob Martinez" -GivenName Bob -Surname Martinez -SamAccountName bmartinez -Path $ou -AccountPassword (Read-Host -AsSecureString) -Enabled $true

New-ADUser -Name "Chris Walker" -GivenName Chris -Surname Walker -SamAccountName cwalker -Path $ou -AccountPassword (Read-Host -AsSecureString) -Enabled $true
==``

Important Notes
Users should always be placed in the correct branch OU
Access is granted through group membership, not OU placement
Password and lockout policies are enforced with Group Policy
##Checkpoint
Three users exist in the Houston → Users OU
Usernames follow a consistent naming standard
No users were created in default containers
If everything looks correct, you’re ready to start creating groups and assigning access.

------------------------------------
Step 6 — Create Security Groups
In this step, you will create security groups and assign users to them. Group membership is how access is granted in Active Directory.

This is one of the most important concepts in real-world AD environments.

How access actually works
In production, users are placed into groups, and groups are granted access to resources. Users should almost never be assigned permissions directly.

1. Create a Centralized _Groups OU
Unlike users and computers, groups are typically stored in a centralized location rather than inside branch OUs.

Open Active Directory Users and Computers
Right-click the domain root (e.g., lab.local)
Select New → Organizational Unit
Name the OU _Groups
Ensure Protect container from accidental deletion is checked
Select OK
2. Create the Helpdesk Group
Right-click the _Groups OU
Select New → Group
Group name: Helpdesk
Group scope: Global
Group type: Security
Select OK
3. Create Additional Groups
Repeat the same process to create the following global security groups:

Accounting
ITSupport
4. Verify Group Creation
Confirm all groups exist inside the _Groups OU
Open a group to verify scope and type
Why Global Security Groups?
Global security groups are commonly used to represent roles or departments, such as Helpdesk or Accounting.

These groups typically contain user accounts and are later nested into resource-specific groups.

5. Add Users to Groups (GUI)
Assign users to groups based on their role.

Add Alice Johnson to Helpdesk
Open the Helpdesk group
Select the Members tab
Select Add
Add user ajohnson
Select OK
Add Remaining Users
Add bmartinez to Accounting
Add cwalker to ITSupport
6. Verify Group Membership
Open each group and confirm correct membership
Group membership changes take effect immediately
PowerShell Equivalent (Optional)
The same tasks can be completed using PowerShell.

==``
$groupsOU = "OU=_Groups,DC=lab,DC=local"

New-ADGroup -Name "Helpdesk" -GroupScope Global -GroupCategory Security -Path $groupsOU
New-ADGroup -Name "Accounting" -GroupScope Global -GroupCategory Security -Path $groupsOU
New-ADGroup -Name "ITSupport" -GroupScope Global -GroupCategory Security -Path $groupsOU

Add-ADGroupMember -Identity "Helpdesk" -Members ajohnson
Add-ADGroupMember -Identity "Accounting" -Members bmartinez
Add-ADGroupMember -Identity "ITSupport" -Members cwalker
==``

Important Notes
Users gain access through group membership
Groups are typically centralized, not branch-based
This structure supports clean scaling and delegation
##Checkpoint
_Groups OU exists at the domain root
Three global security groups exist
Each user belongs to the correct group
If this looks correct, you’re ready to start joining computers to the domain.

--------------------------------

Step 7 — Create a Windows Client VM and Join the Domain
In this step, you will create a second Windows Server virtual machine and join it to your Active Directory domain as a client.

Even though this machine runs Windows Server, it will behave like a standard domain-joined workstation.

Why is a server acting as a client?
In Active Directory, a client is any machine that authenticates to a domain controller and consumes directory services. The operating system does not determine the role — how the machine is used does.

In Azure labs, Windows Server is commonly reused as a client because desktop images may not be available in all regions.

1. Create the Client VM in Azure
Create a new Azure virtual machine
Image: Windows Server 2022 Datacenter
Virtual Machine Name: CLIENT01
Size: Small (B2s or similar)
Resource Group: Same resource group as the domain controller
Virtual Network: Same VNet as the domain controller
The client and domain controller must be on the same virtual network for domain join and authentication to work.

2. Connect to the Client VM
Once deployment completes, connect via RDP
Log in using the local administrator account
3. Configure DNS (Critical Step)
Before joining the domain, the client must use the domain controller for DNS resolution.

Open Network Connections
Right-click the active network adapter → Properties
Select Internet Protocol Version 4 (IPv4)
Select Properties
Set Preferred DNS server to the domain controller’s private IP address
Select OK
Why this matters
Active Directory relies entirely on DNS to locate domain controllers. Incorrect DNS is the most common cause of domain join failures.

4. Join the Domain
Open Settings → System → About
Select Join a domain
Enter your domain name (e.g., lab.local)
Authenticate with a domain administrator account
Restart the computer when prompted
5. What Happens During a Domain Join?
A computer account is created in Active Directory
A secure trust relationship is established with the domain
The client begins authenticating against the domain controller
Group Policy becomes applicable to the machine
This behavior is identical regardless of whether the OS is Windows Server or Windows Desktop.

6. Verify Domain Join
After reboot, log in using a domain user account
Confirm the device shows as domain-joined
Locate the computer account in Active Directory
By default, the computer appears in the Computers container
In the next step, you will move this computer into the correct branch OU.

Is This Common in Real Environments?
Yes. While end users typically run Windows desktop editions, the underlying Active Directory behavior is the same. Many labs, test environments, and jump hosts use Windows Server as a client.

What matters is understanding the authentication flow, DNS dependency, and policy application — not the OS branding.

##Checkpoint
CLIENT01 exists on the same VNet as the domain controller
DNS is set to the domain controller’s private IP
The machine successfully joined the domain
A computer account exists in Active Directory
If all of these are true, your Active Directory environment is now fully functional.

------------------------------------------------------

Step 8 — Test Authentication
In this step, you will verify that Active Directory is working correctly by logging into the client as a domain user.

This confirms that identity, authentication, group membership, and DNS are all functioning end-to-end.

What you’re actually testing
A successful domain login proves that the client can locate a domain controller, authenticate the user, build a security token, and apply group membership — all core Active Directory functions.

1. Log Into the Client as a Domain User
On the client VM login screen, select Other user
Log in using a domain account (for example: LAB\ajohnson)
Enter the password you set earlier
Complete the login
The first login may take longer while the user profile is created.

2. Verify Login Success
The desktop loads successfully
No local account is used
The session is authenticated against the domain
3. Verify the User in Active Directory
On the domain controller:

Open Active Directory Users and Computers
Navigate to _Branches → Houston → Users
Confirm the user account exists and is enabled
4. Verify Group Membership from the Client
On the client VM, open a command prompt and run:

whoami /groups
Review the output and confirm the user is a member of the expected security group (Helpdesk, Accounting, or ITSupport).

What This Command Proves
The user received a valid Kerberos access token
Group membership was evaluated at logon
Authorization decisions can now be made
This command is commonly used by administrators when troubleshooting access and permission issues.

Common Issues and What They Mean
Login fails immediately → DNS or domain join issue
Login works but groups are missing → group membership or token issue
User logs in locally → incorrect username format
Group changes not reflected → user must log out and back in
##Success Criteria
A domain user can log into the client successfully
The user exists in the correct branch OU
Expected group memberships appear in the token
If all of these are true, your Active Directory environment is working correctly.

------------------------------------------------------------
Step 9 — Bonus Tasks (Highly Recommended)
These optional tasks mirror common real-world Active Directory responsibilities. They are not required to complete the lab, but they significantly deepen your understanding of how AD is used in production.

Important note
These tasks introduce concepts you’ll see daily in real environments. In production, changes like these are usually planned, reviewed, and documented. For this lab, you’re free to experiment.

1. Configure Password Policy (Domain-Wide)
Password policies are enforced at the domain level using Group Policy.

Lab context
In real environments, the Default Domain Policy is usually kept minimal or replaced with fine-grained password policies. Editing it here is acceptable for learning purposes.

Open Group Policy Management
Expand Forest → Domains → lab.local
Right-click Default Domain Policy → Edit
Navigate to:
Computer Configuration
 → Policies
 → Windows Settings
 → Security Settings
 → Account Policies
 → Password Policy
Configure Maximum password age
Configure Minimum password length
2. Create a Basic Logon Script
Logon scripts execute automatically when users sign in and are commonly used to map network drives, set environment variables, or display messages.

What is SYSVOL?
SYSVOL is a special shared folder on every domain controller that stores files which must be accessible to all domain users — including Group Policy objects and logon scripts.

When a user logs in, their computer automatically pulls scripts and policies from SYSVOL.

Create a new text file named logon.bat
Add the following line:
    echo Welcome to the domain
Save the file to the domain’s SYSVOL share
The full path will look like:
    C:\Windows\SYSVOL\sysvol\lab.local\scripts
Open Active Directory Users and Computers
Open a user account
On the Profile tab, enter logon.bat in the Logon script field
The script name is enough — Active Directory automatically looks for it inside the SYSVOL scripts folder.

While logon scripts are less common today, they are still frequently encountered in legacy and hybrid environments.

3. Delegate Password Reset Permissions to Helpdesk
Delegation allows non-admin users to perform limited administrative tasks.

Right-click the branch Users OU (for example: _Branches → Houston → Users)
Select Delegate Control
Add the Helpdesk group
Select the following tasks:
Reset user passwords
Force password change at next logon
This is one of the most common real-world delegation scenarios for helpdesk teams.

4. Move the Client Computer into the Correct Branch OU
By default, domain-joined computers are placed in the built-in Computers container.

Open Active Directory Users and Computers
Locate the computer account (e.g., CLIENT01)
Drag the computer into _Branches → Houston → Workstations
This ensures the computer receives the correct Group Policy settings.

Why These Tasks Matter
They reflect real daily Active Directory work
They introduce delegation, policy, and structure concepts
They prepare you for real troubleshooting scenarios
##Completion Checkpoint
Password policy changes are understood (even if reverted)
Delegation is applied to the branch Users OU
The client computer is placed in the correct branch OU
If you completed even one of these tasks, you’re already operating beyond beginner-level Active Directory knowledge.

-------------------------------------------------
Step 10 — Cleanup (Avoid Ongoing Charges)
In this final step, you will remove the Azure resources created for this lab. This prevents unexpected charges and reinforces good cloud hygiene.

Cost awareness and cleanup are real-world responsibilities — not optional extras.

1. Stop (Deallocate) the Virtual Machines
Open the Azure Portal
Navigate to Virtual Machines
Select each VM created for the lab
Select Stop (Deallocate)
Important distinction
In Azure, a VM must be deallocated to stop compute charges. Simply shutting down the OS inside the VM is not sufficient.

Deallocating VMs stops compute billing, but storage and networking resources may still incur costs.

2. Delete the Resource Group (Recommended)
The safest and cleanest way to remove everything is to delete the entire resource group.

Navigate to Resource Groups
Select the lab resource group (for example: ad-lab-rg)
Select Delete resource group
Type the resource group name to confirm
Select Delete
Deleting the resource group removes all associated VMs, disks, public IPs, network interfaces, and virtual networks.

3. Verify All Resources Are Removed
No virtual machines remain
No managed disks remain
No public IP addresses remain
The resource group no longer exists
Azure billing stops only when all billable resources are deleted.

Optional: Keep the Environment
If you plan to continue experimenting or reuse this lab:

Deallocate VMs when not actively using them
Monitor costs in Azure Cost Management
Delete the resource group once finished
Many engineers keep labs temporarily, but very few leave them running indefinitely.

Lab Complete
If you completed this lab end-to-end, you built and validated a functional Active Directory environment using real infrastructure and real workflows.

These are the same foundational skills used daily by IT professionals.

You now understand how identity, authentication, DNS, group membership, and policy work together — not just how to click through a wizard.
