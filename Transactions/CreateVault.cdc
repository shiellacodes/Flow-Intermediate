import FungibleToken from 0x05
import AdrocxToken from 0x06

transaction () {

    let VaultAccess: &AdrocxToken.Vault?

    let VaultCapability: Capability<&AdrocxToken.Vault{FungibleToken.Balance, FungibleToken.Receiver}>

    prepare (signer: AuthAccount) {

        self.VaultAccess =  signer.borrow<&AdrocxToken.Vault>(from: AdrocxToken.VaultStoragePath)
        self.VaultCapability = signer.getCapability<&AdrocxToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AdrocxToken.adminAccess}>(/public/ADRX)

        var condition = (self.VaultAccess.getType() == Type<&AdrocxToken.Vault?>()) ? true  : false

        if condition {
            if self.VaultCapability.check() {
                log("Vault is set up properly")
            } else {
                signer.unlink(/public/ADRX)
                signer.link<&AdrocxToken.Vault{FungibleToken.Receiver, FungibleToken.Balance, AdrocxToken.adminAccess}>(/public/ADRX, target: AdrocxToken.VaultStoragePath)
            }   
        } else {
                let newVault <- AdrocxToken.createEmptyVault()
                signer.unlink(/public/ADRX)
                signer.save(<- newVault, to: AdrocxToken.VaultStoragePath)
                signer.link<&AdrocxToken.Vault{FungibleToken.Receiver, FungibleToken.Balance, AdrocxToken.adminAccess}>(/public/ADRX, target: AdrocxToken.VaultStoragePath)
        }
    }

    execute {
        log(" ADRX vault set-up correctly")
    }

}
 