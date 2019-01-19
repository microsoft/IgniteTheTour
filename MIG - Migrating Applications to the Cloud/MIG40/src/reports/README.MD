# Tailwind Reports

Tailwind has some departments that need to know when SKU quantities have been updated. To address that, Tailwind created a Serverless Function which runs every night at midnight and checks the SQL Server Inventory table for any SKU quantities that have been updated in the last 24 hours. If any are found, it sends an email using Azure Functions SendGrid bindings.

**Note:** Currently this project only works with SQL Server.

## Running Locally

If you'd like to run on Azure, run `make funcdeploy` from the [MIG40 directory](./MIG - Migrating Applications to the Cloud/MIG40) directory.

If not, you can start the local Functions runtime. The timer trigger runs every 24 hours, so you should manually execute the report by navigating to http://localhost:7071/api/RunCreateReport.

### Modifying To/From/Subject

The To and From addresses can be modified in the `CreateReport/function.json` file. By default, the sender is `tailwind.reports@tailwind.com`. That address does not exist, but SendGrid will still send with it. You may consider swapping that out for something else. To send to multiple email addresses, separate addresses with a comma in the "to" field.

