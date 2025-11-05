import { encodeFunctionData, numberToHex} from 'viem'

const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"
export const EventTypeHook = (sdkProvider) => ({
    
    mounted(){

        alert("Hello Creating Event");

        this.handleEvent("event_created", async (create_event_call_data) => {     
           const {partner_wallet_address, to, data} = create_event_call_data
           const calls = [{ to, data }]
           window.dddata = create_event_call_data
           
           const callsId = await sdkProvider.request({
                                method: 'wallet_sendCalls',
                                params: [{
                                    version: '1.0',
                                    chainId: numberToHex(base.constants.CHAIN_IDS.baseSepolia),
                                    from: partner_wallet_address,
                                    calls: calls,
                                    capabilities: {           
                                       paymasterService: {
                                           url: paymasterServiceUrl
                                        }
                                    }
                                }] 
            });

            const status = await sdkProvider.request({
                method: 'wallet_getCallsStatus',
                params: [callsId]
            });

            const txHash = status.receipts[0]?.transactionHash;
            alert(txHash);
            console.log( txHash );
            

        });
    }

});