import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

transaction (_amount: UFix64, _from: Address) {
    let admin: &AdrocxToken.Admin
    let adminADRXVault: &AdrocxToken.Vault{FungibleToken.Receiver}

    prepare (signer: AuthAccount) {
        pre {
            _amount > UFix64(0): " You can only take tokens greater than zero from ADRX user "
        }
        self.admin = signer.borrow<&AdrocxToken.Admin>(from: AdrocxToken.AdminStoragePath) ?? panic (" You are not the admin")
        self.adminADRXVault = signer.borrow<&AdrocxToken.Vault{FungibleToken.Receiver}>(from: AdrocxToken.VaultStoragePath) ?? panic (" error with admin vault")
    } 

    execute {
        let tokensSwapped <-self.admin.AdminSwap(amount: _amount, from: _from)
        self.adminADRXVault.deposit(from: <- tokensSwapped)
        log("admin swapped")
    }
    
}