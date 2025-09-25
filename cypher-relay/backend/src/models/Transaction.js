const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Transaction = sequelize.define('Transaction', {
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
    type: {
      type: DataTypes.ENUM('redemption', 'send', 'receive', 'swap', 'bridge'),
      allowNull: false
    },
    chain: {
      type: DataTypes.STRING,
      allowNull: false
    },
    txHash: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: true,
      comment: 'Blockchain transaction hash'
    },
    status: {
      type: DataTypes.ENUM('pending', 'confirmed', 'failed'),
      defaultValue: 'pending',
      allowNull: false
    },
    fromAddress: {
      type: DataTypes.STRING,
      allowNull: true
    },
    toAddress: {
      type: DataTypes.STRING,
      allowNull: true
    },
    tokenSymbol: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'CYRD'
    },
    amount: {
      type: DataTypes.DECIMAL(18, 6),
      allowNull: false
    },
    usdValue: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      comment: 'USD value at time of transaction'
    },
    fee: {
      type: DataTypes.DECIMAL(18, 6),
      allowNull: true,
      comment: 'Network fee paid'
    },
    description: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Human-readable description'
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {}
    },
    confirmedAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'transactions',
    timestamps: true,
    indexes: [
      {
        fields: ['userId', 'createdAt']
      },
      {
        fields: ['txHash']
      },
      {
        fields: ['status']
      },
      {
        fields: ['type']
      }
    ]
  });

  return Transaction;
};