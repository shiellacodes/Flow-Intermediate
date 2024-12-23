import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

transaction(recipient: Address, amount: UFix64) {

  // Local variables
  let Vault: &AdrocxToken.Vault
  let RecipientVault: &AdrocxToken.Vault{FungibleToken.Receiver}

  prepare(signer: AuthAccount) {
  
    self.Vault = signer.borrow<&AdrocxToken.Vault>(from: AdrocxToken.VaultStoragePath) ?? panic ("You do not own a Vault")
    
    self.RecipientVault = getAccount(recipient).getCapability(/public/rTT)
              .borrow<&AdrocxToken.Vault{FungibleToken.Receiver}>() ?? panic ("The receipient does not own a vault")
  }

  // All execution
  execute {
    let tokens <- self.Vault.withdraw(amount: amount)
    self.RecipientVault.deposit(from: <- tokens)

    log ("transfer succesfully")
    log(amount.toString().concat(" transferred to"))
    log(recipient)
  }
}