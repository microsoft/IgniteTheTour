const { Connection, Request } = require('tedious');

const options = {
  weekday: 'long',
  year: 'numeric',
  month: 'long',
  day: 'numeric'
};

module.exports = function (context, myTimer) {
  context.log("Starting CreateReport")
  getChangedSkus(context)
    .then(data => {
      context.log("Got changed SKUs")
      // Send email only if SKU's have changed
      // if (data.length > 0) {
      //   sendEmail(context, data);
      // } else {
      //   context.done();
      // }
      sendEmail(context, data);
    })
    .catch(err => {
      context.log(`ERROR: ${err}`);
    });
};

/**
 * Sends an email using the Azure Functions binding for SendGrid
 * @param {object} The Function Context
 * @param {object} The data to be passed to the SendGrid template
 */
function sendEmail(context, data) {
  context.done(null, {
    message: {
      /* you can override the to/from settings from function.json here if you would like
        to: 'someone@someplace.com',
        from: 'someone@anotherplace.com'
        */
      personalizations: [
        {
          dynamic_template_data: {
            Subject: `Tailwind SKU Report For ${new Date().toLocaleDateString(
              'en-US',
              options
            )}`,
            Skus: data
          }
        }
      ],
      template_id: process.env.SENDGRID_TEMPLATE_ID
    }
  });
}

/**
 * Executes a query against the database for SKU's changed in the last 24 hours
 * @returns {Promise} Promise object contains result of query
 */
async function getChangedSkus(context) {
  const { Client } = require('pg')
  context.log("Creating postgres client with conn " + process.env.PG_CONNECTION)
  const client = new Client({
    connectionString: process.env.PG_CONNECTION
  })

  context.log("Trying to connect to Postgres")
  await client.connect()
  context.log("Connected to Postgres")

  const query1 = `
  SELECT "Sku", "Quantity", "Modified"
  FROM "Inventory"
  WHERE "Modified" > current_date - interval '1' day
  ORDER BY "Modified" DESC;
  `

  const result = await client.query(query1)

  results = []
  result.rows.forEach(x => {
    let z = {};
    result.fields.forEach(y => {
      z[y.name] = x[y.name]
    })
    results.push(z);
  })

  await client.end()

  return results
}
