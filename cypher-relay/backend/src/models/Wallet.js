const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Wallet = sequelize.define('Wallet', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    chain: {
      type: DataTypes.ENUM('polygon', 'arbitrum', 'solana', 'ethereum', 'avalanche', 'bsc'),
      allowNull: false
    },
    address: {
      type: DataTypes.STRING,
      allowNull: false,
      comment: 'The blockchain address for this wallet'
    },
    mpcKeyShare: {
      type: DataTypes.TEXT,
      allowNull: false,
      comment: 'Encrypted MPC key share for this wallet'
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false
    },
    balance: {
      type: DataTypes.DECIMAL(18, 6),
      defaultValue: 0,
      allowNull: false,
      comment: 'Cached balance of CYRD tokens'
    },
    lastBalanceUpdate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {}
    }
  }, {
    tableName: 'wallets',
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ['userId', 'chain']
      },
      {
        fields: ['address']
      },
      {
        fields: ['isActive']
      }
    ]
  });

  return Wallet;
};