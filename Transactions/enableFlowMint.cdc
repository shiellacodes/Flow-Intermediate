import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

transaction () {
    let admin : &FlowToken.Administrator

    prepare (signer: AuthAccount) {
        self.admin = signer.borrow<&FlowToken.Administrator>(from: /storage/flowTokenAdmin) ?? panic("You are not the admin")
        signer.save(<- self.admin.createNewMinter(allowedAmount: 1000.0), to: /storage/flowTokenMinter)
    }

    execute {
        log("flow minter created successfully")
    }
}