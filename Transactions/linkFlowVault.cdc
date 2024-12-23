import FlowToken from 0x05
import FungibleToken from 0x05

transaction () {

    prepare (signer: AuthAccount) {
            signer.unlink(/public/flowToken)
            signer.link<&FlowToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>(
            /public/flowToken,
            target: /storage/flowToken
            )
    }

    execute {
        log("link Flow successfully")
    }
}