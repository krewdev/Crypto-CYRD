const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Card = sequelize.define('Card', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    cardId: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
      comment: 'Unique identifier printed on the physical card'
    },
    qrCodeHash: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
      comment: 'SHA256 hash of the QR code data'
    },
    value: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      comment: 'USD value of the card'
    },
    tokenAmount: {
      type: DataTypes.DECIMAL(18, 6),
      allowNull: false,
      comment: 'Amount of CYRD tokens (with 6 decimals)'
    },
    nativeChain: {
      type: DataTypes.ENUM('polygon', 'arbitrum', 'solana'),
      allowNull: false,
      defaultValue: 'polygon'
    },
    isRedeemed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    redeemedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    redeemedByUserId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    redeemedWalletAddress: {
      type: DataTypes.STRING,
      allowNull: true
    },
    redemptionTxHash: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Blockchain transaction hash of the redemption'
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'Optional expiration date for the card'
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {},
      comment: 'Additional metadata (batch info, campaign, etc.)'
    }
  }, {
    tableName: 'cards',
    timestamps: true,
    indexes: [
      {
        fields: ['qrCodeHash']
      },
      {
        fields: ['isRedeemed']
      },
      {
        fields: ['redeemedByUserId']
      },
      {
        fields: ['createdAt']
      }
    ]
  });

  return Card;
};