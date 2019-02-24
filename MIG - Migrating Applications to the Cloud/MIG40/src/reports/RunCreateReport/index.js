const index = require('../CreateReport/index');

module.exports = function(context, req) {
  // This is a test function that manually executes the CreateReport timer function
  context.log("Starting RunCreateReport")
  index(context);
};
