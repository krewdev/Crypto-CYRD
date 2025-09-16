const { Sequelize } = require('sequelize');
const logger = require('../utils/logger');

// Initialize Sequelize
const sequelize = new Sequelize(process.env.DATABASE_URL, {
  logging: (msg) => logger.debug(msg),
  pool: {
    min: parseInt(process.env.DATABASE_POOL_MIN) || 2,
    max: parseInt(process.env.DATABASE_POOL_MAX) || 10,
    acquire: 30000,
    idle: 10000
  }
});

// Import models
const User = require('./User')(sequelize);
const Card = require('./Card')(sequelize);
const PathwayProgress = require('./PathwayProgress')(sequelize);
const Transaction = require('./Transaction')(sequelize);
const Wallet = require('./Wallet')(sequelize);

// Define associations
User.hasMany(Card, { as: 'redeemedCards', foreignKey: 'redeemedByUserId' });
User.hasMany(PathwayProgress, { foreignKey: 'userId' });
User.hasMany(Transaction, { foreignKey: 'userId' });
User.hasMany(Wallet, { foreignKey: 'userId' });

Card.belongsTo(User, { as: 'redeemedBy', foreignKey: 'redeemedByUserId' });

PathwayProgress.belongsTo(User, { foreignKey: 'userId' });

Transaction.belongsTo(User, { foreignKey: 'userId' });

Wallet.belongsTo(User, { foreignKey: 'userId' });

module.exports = {
  sequelize,
  User,
  Card,
  PathwayProgress,
  Transaction,
  Wallet
};