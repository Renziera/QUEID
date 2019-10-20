const functions = require('firebase-functions');

exports.listBank = functions.https.onCall((data, context) => {
    return ['Bank Hokage', 'Bank Naruto', 'Bank Sasuke'];
});
