const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const PathwayProgress = sequelize.define('PathwayProgress', {
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
    pathwayId: {
      type: DataTypes.STRING,
      allowNull: false,
      comment: 'Identifier for the pathway (e.g., "unlock_send", "unlock_swap")'
    },
    status: {
      type: DataTypes.ENUM('locked', 'in_progress', 'completed'),
      defaultValue: 'locked',
      allowNull: false
    },
    startedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    currentStep: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false
    },
    totalSteps: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    quizAnswers: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: [],
      comment: 'Array of quiz answers submitted by the user'
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: {}
    }
  }, {
    tableName: 'pathway_progress',
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ['userId', 'pathwayId']
      },
      {
        fields: ['status']
      },
      {
        fields: ['completedAt']
      }
    ]
  });

  return PathwayProgress;
};