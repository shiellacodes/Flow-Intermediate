import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

pub fun main (_address: Address): UFix64 {

      let account: AuthAccount = getAuthAccount(_address)

    // the other way to make sure the vault is the correct type is implemented here, we simply borrow a ADRX Token instead of an AnyResource type
    let Vault = account.borrow<&AdrocxToken.Vault>(from: AdrocxToken.VaultStoragePath) ?? panic("the address does not have a vault")


    // I couldn't use the type identifier because of the buggy flow playground
    // otherwise the code would have been like:
    // Vault.getType().identifier == "A.02.redTibbyToken.Vault"
    // makes sure the vault is the correct type (redTibbyToken)
    assert(
        Vault.getType() == Type<@AdrocxToken.Vault>(),
        message: "This is not the correct type. No hacking me today!"
        )

      account.unlink(/public/ADRX)
      account.link<&AdrocxToken.Vault{FungibleToken.Balance}>(/public/ADRX, target: AdrocxToken.VaultStoragePath)
      let wallet = getAccount(_address).getCapability<&AdrocxToken.Vault{FungibleToken.Balance}>(/public/ADRX).borrow() ?? panic ("error")


    log("will return Vault balance")
    log(wallet.balance)
    return wallet.balance
}