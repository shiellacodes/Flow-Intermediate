import AdrocxToken from 0x06
import FungibleToken from 0x05

transaction () {

    prepare (signer: AuthAccount) {
        signer.unlink(/public/flowToken)
        signer.link<&AdrocxToken.Vault{FungibleToken.Receiver, FungibleToken.Balance, AdrocxToken.adminAccess}>(/public/ADRX, target: AdrocxToken.VaultStoragePath)
    }

    execute {
        log("link ADRX successfully")
    }
}
 