const joi = require('joi');

const cardValidation = {
  redeem: joi.object({
    qrData: joi.string().required().regex(/^CYRD:.+$/),
    deviceId: joi.string().uuid().required(),
    platform: joi.string().valid('ios', 'android').required(),
    appVersion: joi.string().optional()
  }),
  
  checkStatus: {
    params: joi.object({
      cardId: joi.string().required()
    })
  },
  
  verify: joi.object({
    qrData: joi.string().required().regex(/^CYRD:.+$/)
  })
};

module.exports = {
  cardValidation
};