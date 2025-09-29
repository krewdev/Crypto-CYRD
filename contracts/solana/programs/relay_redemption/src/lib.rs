use anchor_lang::prelude::*;
use anchor_spl::token::{self, Mint, Token, TokenAccount, Transfer};

declare_id!("RELAYREDEMP1oN11111111111111111111111111111");

#[program]
pub mod relay_redemption {
    use super::*;

    pub fn redeem(ctx: Context<Redeem>, amount: u64) -> Result<()> {
        // In production, restrict this instruction via a backend signer PDA or allowlist
        let cpi_accounts = Transfer {
            from: ctx.accounts.treasury_token_account.to_account_info(),
            to: ctx.accounts.user_token_account.to_account_info(),
            authority: ctx.accounts.treasury_authority.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let seeds: &[&[&[u8]]] = &[]; // placeholder, use PDA in production
        token::transfer(CpiContext::new_with_signer(cpi_program, cpi_accounts, seeds), amount)?;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Redeem<'info> {
    /// CHECK: In production, make this a PDA with signer seeds
    #[account(mut)]
    pub treasury_authority: AccountInfo<'info>,
    #[account(mut)]
    pub treasury_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub user_token_account: Account<'info, TokenAccount>,
    pub token_mint: Account<'info, Mint>,
    pub token_program: Program<'info, Token>,
}
