using Microsoft.WindowsAzure.Storage;
using Model;
using System;

namespace DataAccess
{
    public class StorageValidator : IValidate
    {
        public bool Validate()
        {
            // check for  storage credentials
            var storageConnection = Environment.GetEnvironmentVariable(Globals.STORAGE);
            if (string.IsNullOrWhiteSpace(storageConnection))
            {
                throw new Exception("STORAGE_CONNECTION not found.");
            }

            // but are they valid?
            var storageAccount = CloudStorageAccount.Parse(storageConnection);

            return true;
        }
    }
}
