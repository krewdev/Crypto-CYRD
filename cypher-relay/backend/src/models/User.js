const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    deviceId: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
      comment: 'Unique device identifier for the user'
    },
    platform: {
      type: DataTypes.ENUM('ios', 'android'),
      allowNull: false
    },
    appVersion: {
      type: DataTypes.STRING,
      allowNull: true
    },
    kycTier: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
      comment: '0: No KYC, 1: Basic KYC completed'
    },
    kycData: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {},
      comment: 'Encrypted KYC information'
    },
    totalRedeemed: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      allowNull: false,
      comment: 'Total USD value redeemed by user'
    },
    settings: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {
        currency: 'USD',
        notifications: true,
        biometricEnabled: false
      }
    },
    cloudBackupEnabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    socialRecoveryContacts: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: [],
      comment: 'Encrypted list of social recovery contacts'
    },
    lastActiveAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      allowNull: false
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {}
    }
  }, {
    tableName: 'users',
    timestamps: true,
    indexes: [
      {
        fields: ['deviceId']
      },
      {
        fields: ['kycTier']
      },
      {
        fields: ['lastActiveAt']
      }
    ]
  });

  return User;
};