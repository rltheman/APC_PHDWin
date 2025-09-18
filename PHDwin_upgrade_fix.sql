/*
* Step 1
* If PHDWin is throwing fits with an upgrade. Close PHD Win, then run this script
*/
DROP DATABASE PhdReports;
GO
DROP DATABASE PhdDefaults;
GO
DROP DATABASE PhdRules;
GO
DROP DATABASE PhdUsers;

/*
 * Step 2 
 * Go into PHDWin and create a new database using PHDWin
 * Close the database and reopen the old database. 
 * Reopening the old database will run the upgrade
*/
