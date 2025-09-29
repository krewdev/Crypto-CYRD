"""init

Revision ID: 20250916_000001
Revises: 
Create Date: 2025-09-16 00:00:01.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "20250916_000001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "cards",
        sa.Column("card_id", sa.String(), primary_key=True),
        sa.Column("qr_code_hash", sa.String(), nullable=False, unique=True),
        sa.Column("value_cyrd", sa.Integer(), nullable=False),
        sa.Column("token_type", sa.String(), nullable=False),
        sa.Column("native_chain", sa.String(), nullable=False),
        sa.Column("is_redeemed", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
        sa.Column("redeemed_at", sa.DateTime(timezone=True), nullable=True),
    )

    op.create_index("ix_cards_qr_code_hash", "cards", ["qr_code_hash"], unique=True)

    op.create_table(
        "users",
        sa.Column("user_id", sa.String(), primary_key=True),
        sa.Column("device_id", sa.String(), nullable=False),
        sa.Column("wallet_address_polygon", sa.String(), nullable=True),
        sa.Column("wallet_address_arbitrum", sa.String(), nullable=True),
        sa.Column("wallet_address_solana", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_users_device_id", "users", ["device_id"], unique=False)

    op.create_table(
        "pathways_progress",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("pathway_id", sa.String(), nullable=False),
        sa.Column("status", sa.String(), nullable=False, server_default=sa.text("'locked'")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_pathways_user_id", "pathways_progress", ["user_id"], unique=False)

    op.create_table(
        "transaction_logs",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("chain", sa.String(), nullable=False),
        sa.Column("tx_type", sa.String(), nullable=False),
        sa.Column("amount_cyrd", sa.Integer(), nullable=False),
        sa.Column("tx_hash", sa.String(), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_tx_user_id", "transaction_logs", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_tx_user_id", table_name="transaction_logs")
    op.drop_table("transaction_logs")

    op.drop_index("ix_pathways_user_id", table_name="pathways_progress")
    op.drop_table("pathways_progress")

    op.drop_index("ix_users_device_id", table_name="users")
    op.drop_table("users")

    op.drop_index("ix_cards_qr_code_hash", table_name="cards")
    op.drop_table("cards")
