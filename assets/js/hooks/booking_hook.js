export let BasePaymentHook = (sdkProvider) => ({    

    
const permission = await requestSpendPermission({
  account: "0x...",
  spender: "0x...",
  token: "0x...",
  chainId: 8453, // or any other supported chain
  allowance: 1_000_000n,
  periodInDays: 1,
  provider: sdkProvider,
});
    mounted(){
        this.el.addEventListener("click" ,() =>{
            console.log("Will process payment here");
        })
    }

})