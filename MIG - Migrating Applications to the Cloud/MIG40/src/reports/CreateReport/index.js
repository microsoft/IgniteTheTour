const { Connection, Request } = require('tedious');

const options = {
  weekday: 'long',
  year: 'numeric',
  month: 'long',
  day: 'numeric'
};

module.exports = function(context, myTimer) {
  getChangedSkus()
    .then(data => {
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
async function getChangedSkus() {
  const { Client } = require('pg')
  const client = new Client(process.env.PG_CONNECTION)

  await client.connect()

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